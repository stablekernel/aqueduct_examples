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
  @managedPrimaryKey
  int id;

  @ManagedColumnAttributes(nullable: true)
  String title;

  String contents;

  @ManagedColumnAttributes(indexed: true)
  DateTime createdAt;

  @ManagedColumnAttributes(indexed: true)
  DateTime updatedAt;

  @ManagedRelationship(#notes, onDelete: ManagedRelationshipDeleteRule.cascade, isRequired: true)
  User owner;
}
