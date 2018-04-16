import 'chat.dart';
import 'chat_room.dart';

class WebsocketController extends Controller {
  WebsocketController(this.room);

  final ChatRoom room;

  @override
  Future<RequestOrResponse> handle(Request request) async {
    final websocket = await WebSocketTransformer.upgrade(request.raw);
    room.add(websocket);

    return null;
  }
}

