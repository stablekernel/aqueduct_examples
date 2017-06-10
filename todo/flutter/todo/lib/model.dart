
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

  Map<String, dynamic> asMap() =>
    {
      "id": id,
      "email": email
    };
}