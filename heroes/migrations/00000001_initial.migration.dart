import 'dart:async';

import 'package:aqueduct/aqueduct.dart';

class Migration1 extends Migration {
  @override
  Future upgrade() async {
    database.createTable(SchemaTable(
      "_Hero",
      [
        SchemaColumn("id", ManagedPropertyType.bigInteger,
            isPrimaryKey: true,
            autoincrement: true,
            isIndexed: false,
            isNullable: false,
            isUnique: false),
        SchemaColumn("name", ManagedPropertyType.string,
            isPrimaryKey: false,
            autoincrement: false,
            isIndexed: false,
            isNullable: false,
            isUnique: true),
      ],
    ));
  }

  @override
  Future downgrade() async {}

  @override
  Future seed() async {
    final heroNames = ["Mr. Nice", "Narco", "Bombasto", "Celeritas", "Magneta"];

    for (final heroName in heroNames) {
      await database.store.execute("INSERT INTO _Hero (name) VALUES (@name)",
          substitutionValues: {"name": heroName});
    }
  }
}
