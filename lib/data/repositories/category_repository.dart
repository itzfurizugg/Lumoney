import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

class CategoryRepository {
  CategoryRepository(this.db);
  final AppDatabase db;
  static const _uuid = Uuid();

  Future<void> create({required String name, required String type, String icon = 'category', int color = 0xFF757575}) async {
    await db.into(db.categories).insert(CategoriesCompanion.insert(
          id: _uuid.v4(),
          name: name,
          type: type,
          icon: Value(icon),
          color: Value(color),
        ));
  }

  Future<void> deleteCategory(String id) async {
    await (db.delete(db.categories)..where((c) => c.id.equals(id))).go();
  }
}
