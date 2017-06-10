import 'chat.dart';
import 'chat_room.dart';
import 'upgrade_controller.dart';

class ChatSink extends RequestSink {
  ChatSink(ApplicationConfiguration appConfig) : super(appConfig) {
    logger.onRecord.listen((rec) {
      print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}");
    });
    chatRoom = new ChatRoom(messageHub);

    messageHub.listen((Map<String, dynamic> messageFromSibling) {
      switch (messageFromSibling["event"]) {
        case "broadcast": chatRoom?.sendBytesToAllConnections(messageFromSibling["data"]);
      }
    });
  }

  ChatRoom chatRoom;

  @override
  void setupRouter(Router router) {
    router
      .route("/connect")
      .pipe(new WebsocketController(chatRoom));
  }
}