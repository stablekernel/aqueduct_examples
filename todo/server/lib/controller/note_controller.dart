import '../todo.dart';
import '../model/note.dart';
import '../model/user.dart';

class NoteController extends HTTPController {
  NoteController(this.authServer);

  AuthServer authServer;

  @httpGet
  Future<Response> getNotes({@HTTPQuery("created_after") DateTime createdAfter}) async {
    var query = new Query<Note>()
      ..where.owner.id = whereEqualTo(request.authorization.resourceOwnerIdentifier);

    if (createdAfter != null) {
      query.where.createdAt = whereGreaterThan(createdAfter);
    }

    return new Response.ok(await query.fetch());
  }

  @httpGet
  Future<Response> getNote(@HTTPPath("id") int id) async {
    var requestingUserID = request.authorization.resourceOwnerIdentifier;
    var query = new Query<Note>()
      ..where.id = whereEqualTo(id)
      ..where.owner.id = whereEqualTo(requestingUserID);

    var u = await query.fetchOne();
    if (u == null) {
      return new Response.notFound();
    }

    return new Response.ok(u);
  }

  @httpPost
  Future<Response> createNote(@HTTPBody() Note note) async {
    note.owner = new User()
      ..id = request.authorization.resourceOwnerIdentifier;

    var query = new Query<Note>()
      ..values = note;

    return new Response.ok(await query.insert());
  }

  @httpPut
  Future<Response> updateNote(@HTTPPath("id") int id, @HTTPBody() Note note) async {
    var requestingUserID = request.authorization.resourceOwnerIdentifier;
    var query = new Query<Note>()
      ..where.id = whereEqualTo(id)
      ..where.owner.id = whereEqualTo(requestingUserID)
      ..values = note;

    var u = await query.updateOne();
    if (u == null) {
      return new Response.notFound();
    }

    return new Response.ok(u);
  }

  @httpDelete
  Future<Response> deleteNote(@HTTPPath("id") int id) async {
    var requestingUserID = request.authorization.resourceOwnerIdentifier;
    var query = new Query<Note>()
      ..where.id = whereEqualTo(id)
      ..where.owner.id = whereEqualTo(requestingUserID);

    if (await query.delete() > 0) {
      return new Response.ok(null);
    }

    return new Response.notFound();
  }
}
