import 'package:aqueduct/aqueduct.dart';
import 'dart:async';

class Migration1 extends Migration {
  @override
  Future upgrade() async {
    database.createTable(new SchemaTable("_authclient", [
      new SchemaColumn("id", ManagedType.string, isPrimaryKey: true, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
      new SchemaColumn("hashedSecret", ManagedType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false),
      new SchemaColumn("salt", ManagedType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false),
      new SchemaColumn("redirectURI", ManagedType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: true),
      new SchemaColumn("allowedScope", ManagedType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false),
    ]));

    database.createTable(new SchemaTable("_User", [
      new SchemaColumn("email", ManagedType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: true),
      new SchemaColumn("id", ManagedType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false),
      new SchemaColumn("username", ManagedType.string, isPrimaryKey: false, autoincrement: false, isIndexed: true, isNullable: false, isUnique: true),
      new SchemaColumn("hashedPassword", ManagedType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
      new SchemaColumn("salt", ManagedType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
    ]));

    database.createTable(new SchemaTable("_Note", [
      new SchemaColumn("id", ManagedType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false),
      new SchemaColumn("title", ManagedType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false),
      new SchemaColumn("contents", ManagedType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
      new SchemaColumn("createdAt", ManagedType.datetime, isPrimaryKey: false, autoincrement: false, isIndexed: true, isNullable: false, isUnique: false),
      new SchemaColumn("updatedAt", ManagedType.datetime, isPrimaryKey: false, autoincrement: false, isIndexed: true, isNullable: false, isUnique: false),
      new SchemaColumn.relationship("owner", ManagedType.bigInteger, relatedTableName: "_User", relatedColumnName: "id", rule: DeleteRule.cascade, isNullable: false, isUnique: false),
    ]));

    database.createTable(new SchemaTable("_authtoken", [
      new SchemaColumn("id", ManagedType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false),
      new SchemaColumn("code", ManagedType.string, isPrimaryKey: false, autoincrement: false, isIndexed: true, isNullable: true, isUnique: true),
      new SchemaColumn("accessToken", ManagedType.string, isPrimaryKey: false, autoincrement: false, isIndexed: true, isNullable: true, isUnique: true),
      new SchemaColumn("refreshToken", ManagedType.string, isPrimaryKey: false, autoincrement: false, isIndexed: true, isNullable: true, isUnique: true),
      new SchemaColumn("scope", ManagedType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false),
      new SchemaColumn("issueDate", ManagedType.datetime, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),
      new SchemaColumn("expirationDate", ManagedType.datetime, isPrimaryKey: false, autoincrement: false, isIndexed: true, isNullable: false, isUnique: false),
      new SchemaColumn("type", ManagedType.string, isPrimaryKey: false, autoincrement: false, isIndexed: true, isNullable: true, isUnique: false),
      new SchemaColumn.relationship("resourceOwner", ManagedType.bigInteger, relatedTableName: "_User", relatedColumnName: "id", rule: DeleteRule.cascade, isNullable: false, isUnique: false),
      new SchemaColumn.relationship("client", ManagedType.string, relatedTableName: "_authclient", relatedColumnName: "id", rule: DeleteRule.cascade, isNullable: false, isUnique: false),
    ]));

  }

  @override
  Future downgrade() async {
  }

  @override
  Future seed() async {
  }
}
