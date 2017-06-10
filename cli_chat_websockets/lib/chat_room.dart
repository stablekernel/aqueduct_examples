import 'dart:convert';
import 'dart:io';

class Chatter {
  Chatter(this.socket);

  String name = "anonymous";
  WebSocket socket;
}

class ChatRoom {
  ChatRoom(this.broadcastSink) {
    var json = new JsonCodec();
    var utf8 = new Utf8Codec();
    messageCodec = json.fuse(utf8);
  }

  Sink<dynamic> broadcastSink;
  Codec messageCodec;
  List<Chatter> chatters = [];

  void add(WebSocket socket) {
    var chatter = new Chatter(socket);
    socket.listen((message) {
      var payload = messageCodec.decode(message);
      handleMessage(payload, from: chatter);
    }, cancelOnError: true);


    chatters.add(chatter);
    socket.done.then((_) {
      chatters.remove(chatter);
    });
  }

  void handleMessage(Map<String, dynamic> payload, {Chatter from}) {
    var event = payload["event"];
    switch (event) {
      case "name": {
        from?.name = payload["data"] ?? "anonymous";
        from?.socket?.add(messageCodec.encode({"event": "name_ack", "data": from?.name}));
      } break;

      case "message": {
        sendMessage(payload["data"], from: from);
      } break;

      default: {
        from?.socket?.add(
          messageCodec.encode({"event": "error", "data": "unknown command '$event'"}));
      }
    }
  }

  void sendMessage(String message, {Chatter from}) {
    var bytes = messageCodec.encode({"event": "message", "data" : "${from?.name ?? "global"}: $message"});
    sendBytesToAllConnections(bytes);
    sendBytesToOtherIsolates(bytes);
  }

  void sendBytesToAllConnections(List<int> bytes) {
    chatters.forEach((c) {
      c.socket.add(bytes);
    });
  }

  void sendBytesToOtherIsolates(List<int> bytes) {
    broadcastSink.add({"event": "broadcast", "data": bytes});
  }
}