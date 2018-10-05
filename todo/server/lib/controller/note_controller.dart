import '../todo.dart';
import '../model/note.dart';
import '../model/user.dart';

class NoteController extends ResourceController {
  NoteController(this.context, this.authServer);

  final AuthServer authServer;
  final ManagedContext context;

  @Operation.get()
  Future<Response> getNotes({@Bind.query("created_after") DateTime createdAfter}) async {
    var query =  Query<Note>(context)
      ..where((n) => n.owner).identifiedBy(request.authorization.ownerID);

    if (createdAfter != null) {
      query.where((n) => n.createdAt).greaterThan(createdAfter);
    }

    return Response.ok(await query.fetch());
  }

  @Operation.get("id")
  Future<Response> getNote(@Bind.path("id") int id) async {
    var requestingUserID = request.authorization.ownerID;
    var query = new Query<Note>(context)
      ..where((n) => n.id).equalTo(id)
      ..where((n) => n.owner).identifiedBy(requestingUserID);

    var u = await query.fetchOne();
    if (u == null) {
      return new Response.notFound();
    }

    return new Response.ok(u);
  }

  @Operation.post()
  Future<Response> createNote(@Bind.body() Note note) async {
    note.owner = new User()
      ..id = request.authorization.ownerID;

    return Response.ok(await Query.insertObject(context, note));
  }

  @Operation.put("id")
  Future<Response> updateNote(@Bind.path("id") int id, @Bind.body() Note note) async {
    var requestingUserID = request.authorization.ownerID;
    var query = Query<Note>(context)
      ..where((n) => n.id).equalTo(id)
      ..where((n) => n.owner).identifiedBy(requestingUserID)
      ..values = note;

    var u = await query.updateOne();
    if (u == null) {
      return Response.notFound();
    }

    return Response.ok(u);
  }

  @Operation.delete("id")
  Future<Response> deleteNote(@Bind.path("id") int id) async {
    var requestingUserID = request.authorization.ownerID;
    var query = Query<Note>(context)
      ..where((n) => n.id).equalTo(id)
      ..where((n) => n.owner).identifiedBy(requestingUserID);

    if (await query.delete() > 0) {
      return Response.ok(null);
    }

    return Response.notFound();
  }
}
