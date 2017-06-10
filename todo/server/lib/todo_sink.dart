import 'todo.dart';

import 'controller/identity_controller.dart';
import 'controller/register_controller.dart';
import 'controller/note_controller.dart';
import 'model/user.dart';

/*
note: figure out if you want to store initial migration in git or make user generate it

create database todo_app;
create user todo with password 'todo';
grant all on database todo_app to todo;
aqueduct db generate
aqueduct db upgrade --connect postgres://todo:todo@localhost:5432/todo_app

aqueduct auth add-client --id com.dart.demo --secret abcd --connect postgres://todo:todo@localhost:5432/todo_app

aqueduct serve --port 8082
 */

class TodoSink extends RequestSink {
  TodoSink(ApplicationConfiguration appConfig) : super(appConfig) {
    logger.onRecord.listen((rec) => print("$rec"));

    var options = new TodoConfiguration(appConfig.configurationFilePath);

    ManagedContext.defaultContext = contextWithConnectionInfo(options.database);

    var authStorage = new ManagedAuthStorage<User>(ManagedContext.defaultContext);
    authServer = new AuthServer(authStorage);
  }

  AuthServer authServer;

  static Future initializeApplication(ApplicationConfiguration appConfig) async {
    if (appConfig.configurationFilePath == null) {
      throw new ApplicationStartupException(
          "No configuration file found. See README.md.");
    }
  }

  @override
  void setupRouter(Router router) {
    /* OAuth 2.0 Resource Owner Grant Endpoint */
    router.route("/auth/token").generate(() => new AuthController(authServer));

    /* Create an account */
    router
        .route("/register")
        .pipe(new Authorizer.basic(authServer))
        .generate(() => new RegisterController(authServer));

    /* Gets profile for user with bearer token */
    router
        .route("/me")
        .pipe(new Authorizer.bearer(authServer))
        .generate(() => new IdentityController());

    /* Creates, updates, deletes and gets notes */
    router
        .route("/notes/[:id]")
        .pipe(new Authorizer(authServer))
        .generate(() => new NoteController(authServer));
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

  /*
   * Overrides
   */

  @override
  Map<String, APISecurityScheme> documentSecuritySchemes(
      PackagePathResolver resolver) {
    return authServer.documentSecuritySchemes(resolver);
  }
}

class TodoConfiguration extends ConfigurationItem {
  TodoConfiguration(String fileName) : super.fromFile(fileName);

  DatabaseConnectionConfiguration database;
}
