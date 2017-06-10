import 'package:todo/todo.dart';
import 'package:aqueduct/aqueduct.dart';

Future main() async {
  var app = new Application<TodoSink>()
    ..configuration.configurationFilePath = "config.yaml"
    ..configuration.port = 8082;
  await app.start();
}