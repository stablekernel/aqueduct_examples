import 'chat.dart';
import 'chat_room.dart';

class WebsocketController extends RequestController {
  WebsocketController(this.room);

  ChatRoom room;

  @override
  Future<RequestOrResponse> processRequest(Request request) async {
    var websocket = await WebSocketTransformer.upgrade(request.innerRequest);
    room.add(websocket);

    return null;
  }
}

