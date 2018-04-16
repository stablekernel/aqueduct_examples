import '../todo.dart';
import 'user.dart';

class Note extends ManagedObject<_Note> implements _Note {
  @override
  void willUpdate() {
    updatedAt = new DateTime.now().toUtc();
  }

  @override
  void willInsert() {
    createdAt = new DateTime.now().toUtc();
    updatedAt = new DateTime.now().toUtc();
  }
}

class _Note {
  @primaryKey
  int id;

  @Column(nullable: true)
  String title;

  String contents;

  @Column(indexed: true)
  DateTime createdAt;

  @Column(indexed: true)
  DateTime updatedAt;

  @Relate(#notes, onDelete: DeleteRule.cascade, isRequired: true)
  User owner;
}
