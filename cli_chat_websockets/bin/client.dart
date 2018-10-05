import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:args/args.dart';

Future main(List<String> args) async {
  var parser = new ArgParser()
      ..addOption("connect-url", abbr: "c", defaultsTo: "ws://localhost:8081/connect");
  var values = parser.parse(args);
  
  var url = values["connect-url"];
  var websocket = await WebSocket.connect(url);
  print("Connected to server $url\nType any text to send a message.\nType '/name <name>' to name yourself.");

  var codec = new JsonCodec().fuse(new Utf8Codec());
  websocket.listen((bytes) {
    var payload = codec.decode(bytes) as Map<String, dynamic>;

    switch (payload["event"]) {
      case "message": stdout.writeln(payload["data"]); break;
      case "name_ack": stdout.writeln("You are now named: ${payload["data"]}"); break;
      case "error": stdout.writeln("Error: ${payload["data"]}"); break;
      default: stdout.writeln("unknown event from server: ${payload["event"]}");
    }
  });

  var regex = new RegExp(r"^/name ([A-Za-z0-9]+)$");
  stdin.listen((input) {
    var asString = utf8.decode(input).trimRight();
    var nameMatch = regex.firstMatch(asString);
    if (nameMatch != null) {
      websocket.add(codec.encode({"event": "name", "data": nameMatch.group(1)}));
    } else {
      websocket.add(codec.encode({"event": "message", "data": asString}));
    }
  });
}