class Note {
  Note();

  Note.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    title = map["title"];
    contents = map["contents"];
    createdAt = DateTime.parse(map["createdAt"]);
    updatedAt = DateTime.parse(map["updatedAt"]);
    owner = new User.fromMap(map["owner"]);
  }

  int id;
  String title;
  String contents;
  DateTime createdAt;
  DateTime updatedAt;
  User owner;

  Map<String, dynamic> asMap() =>
    {
      "title": title,
      "contents": contents,
    };
}

class User {
  User.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    email = map["email"];
  }

  int id;
  String email;
  List<Note> notes = [];
  AuthorizationToken token;

  bool get isAuthenticated => token != null && !token.isExpired;

  Map<String, dynamic> asMap() =>
    {
      "id": id,
      "email": email
    };
}

class AuthorizationToken {
  AuthorizationToken.fromMap(Map<String, dynamic> map) {
    accessToken = map["access_token"];
    refreshToken = map["refresh_token"];
    expiresAt = new DateTime.now().add(new Duration(seconds: map["expires_in"]));
  }
  String accessToken;
  String refreshToken;
  DateTime expiresAt;

  String get authorizationHeaderValue => "Bearer $accessToken";

  bool get isExpired =>
    expiresAt.difference(new DateTime.now()).inSeconds < 0;
}