import 'rest_postgres.dart';

import 'model/model.dart';

class RestPostgresSink extends RequestSink {
  RestPostgresSink(ApplicationConfiguration appConfig) : super(appConfig) {
    var options = new RestPostgresConfiguration(appConfig.configurationFilePath);
    ManagedContext.defaultContext = contextWithConnectionInfo(options.database);
  }
  
  @override
  void setupRouter(Router router) {
    ManagedContext.defaultContext.dataModel.entities.forEach((e) {
      router
          .route("/${e.tableName.toLowerCase()}/[:id]")
          .generate(() => new ManagedObjectController.forEntity(e));
    });
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