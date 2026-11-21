import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Wallets, Categories, Transactions, SavingsGoals, SavingsEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedDefaults();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(transactions, transactions.title);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'lumoney');
  }

  Future<void> _seedDefaults() async {
    const uuid = Uuid();
    await batch((b) {
      b.insertAll(categories, [
        for (final name in ['Makanan', 'Transport', 'Belanja', 'Tagihan', 'Hiburan', 'Kesehatan', 'Pendidikan', 'Lainnya'])
          CategoriesCompanion.insert(
            id: uuid.v4(),
            name: name,
            type: 'expense',
            icon: const Value('category'),
            color: const Value(0xFF757575),
            isDefault: const Value(true),
          ),
        for (final name in ['Gaji', 'Bonus', 'Hadiah', 'Lainnya'])
          CategoriesCompanion.insert(
            id: uuid.v4(),
            name: name,
            type: 'income',
            icon: const Value('category'),
            color: const Value(0xFF2E7D32),
            isDefault: const Value(true),
          ),
      ]);
    });
  }
}
