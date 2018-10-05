import 'package:rest_postgres/rest_postgres.dart';

Future main() async {
  var app = new Application<Postgrest>()
      ..options.configurationFilePath = "config.yaml"
      ..options.port = 8000;

  await app.start(numberOfInstances: 2);

  print("Application started on port: ${app.options.port}.");
  print("Use Ctrl-C (SIGINT) to stop running the application.");
}