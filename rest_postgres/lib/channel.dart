import 'rest_postgres.dart';

import 'model/model.dart';

class Postgrest extends ApplicationChannel {
  ManagedContext context;

  @override
  Future prepare() async {
    final config = RestPostgresConfiguration(options.configurationFilePath);
    context = contextWithConnectionInfo(config.database);
  }

  @override
  Controller get entryPoint {
    final router = Router();

    context.dataModel.entities.forEach((e) {
      router
          .route("/${e.tableName.toLowerCase()}/[:id]")
          .link(() => new ManagedObjectController.forEntity(e, context));
    });

    return router;
  }

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

class RestPostgresConfiguration extends ConfigurationItem {
  RestPostgresConfiguration(String fileName) : super.fromFile(fileName);

  DatabaseConnectionConfiguration database;
}