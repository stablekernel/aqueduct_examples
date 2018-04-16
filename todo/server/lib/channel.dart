import 'todo.dart';

import 'controller/identity_controller.dart';
import 'controller/register_controller.dart';
import 'controller/note_controller.dart';
import 'model/user.dart';

class Todo extends ApplicationChannel {
  ManagedContext context;
  AuthServer authServer;

  @override
  Future prepare() async {
    logger.onRecord.listen((rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    final config = TodoConfiguration(options.configurationFilePath);
    context = contextWithConnectionInfo(config.database);

    authServer = AuthServer(ManagedAuthDelegate<User>(context));
  }

  @override
  Controller get entryPoint {
    final router = Router();
    /* OAuth 2.0 Resource Owner Grant Endpoint */
    router.route("/auth/token").link(() => AuthController(authServer));

    /* Create an account */
    router
        .route("/register")
        .link(() => Authorizer.basic(authServer))
        .link(() => RegisterController(context, authServer));

    /* Gets profile for user with bearer token */
    router
        .route("/me")
        .link(() => Authorizer.bearer(authServer))
        .link(() => IdentityController(context));

    /* Creates, updates, deletes and gets notes */
    router
        .route("/notes/[:id]")
        .link(() => Authorizer(authServer))
        .link(() => NoteController(context, authServer));

    router
      .route("/*")
      .link(() => ReroutingFileController("web"));

    return router;
  }

  /*
   * Helper methods
   */

  ManagedContext contextWithConnectionInfo(
      DatabaseConnectionConfiguration connectionInfo) {
    var dataModel = new ManagedDataModel.fromCurrentMirrorSystem();
    var psc = new PostgreSQLPersistentStore.fromConnectionInfo(
        connectionInfo.username,
        connectionInfo.password,
        connectionInfo.host,
        connectionInfo.port,
        connectionInfo.databaseName);

    return new ManagedContext(dataModel, psc);
  }
}

class TodoConfiguration extends ConfigurationItem {
  TodoConfiguration(String fileName) : super.fromFile(fileName);

  DatabaseConnectionConfiguration database;
}


class ReroutingFileController extends HTTPFileController {
  ReroutingFileController(String directory) : super(directory);

  @override
  Future<RequestOrResponse> handle(Request req) async {
    Response potentialResponse = await super.handle(req);
    final acceptsHTML = req.raw.headers.value(HttpHeaders.ACCEPT).contains("text/html");

    if (potentialResponse.statusCode == 404 && acceptsHTML)  {
        return new Response(302, {
          HttpHeaders.LOCATION: "/",
          "X-JS-Route": req.path.remainingPath
        }, null);
    }

    return potentialResponse;
  }
}