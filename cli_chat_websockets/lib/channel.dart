import 'chat.dart';
import 'chat_room.dart';
import 'upgrade_controller.dart';

class Chat extends ApplicationChannel {
  ChatRoom chatRoom;

  @override
  Controller get entryPoint {
    final router = Router();
    router
      .route("/connect")
      .link(() => new WebsocketController(chatRoom));
    return router;
  }

  @override
  Future prepare() async {
    logger.onRecord.listen((rec) {
      print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}");
    });
    chatRoom = new ChatRoom(messageHub);

    messageHub.listen((event) {
      Map<String, dynamic> message = event;

      switch (message["event"]) {
        case "broadcast": chatRoom?.sendBytesToAllConnections(message["data"]);
      }
    });
  }
}