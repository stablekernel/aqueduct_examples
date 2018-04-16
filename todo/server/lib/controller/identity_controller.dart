import '../todo.dart';
import '../model/user.dart';

class IdentityController extends ResourceController {
  IdentityController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getIdentity() async {
    var q = Query<User>(context)
      ..where((u) => u.id).equalTo(request.authorization.resourceOwnerIdentifier);

    var u = await q.fetchOne();
    if (u == null) {
      return  Response.notFound();
    }

    return Response.ok(u);
  }
}
