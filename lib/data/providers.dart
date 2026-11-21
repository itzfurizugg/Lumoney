import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final walletsProvider = StreamProvider<List<Wallet>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.wallets)
        ..where((w) => w.isArchived.equals(false))
        ..orderBy([(w) => OrderingTerm.asc(w.createdAt)]))
      .watch();
});

final categoriesProvider = StreamProvider<List<Category>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.categories)..orderBy([(c) => OrderingTerm.asc(c.name)])).watch();
});

final transactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.transactions)
        ..orderBy([(t) => OrderingTerm.desc(t.date), (t) => OrderingTerm.desc(t.createdAt)]))
      .watch();
});

final savingsGoalsProvider = StreamProvider<List<SavingsGoal>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.savingsGoals)..orderBy([(g) => OrderingTerm.desc(g.createdAt)])).watch();
});

final savingsEntriesProvider = StreamProvider.family<List<SavingsEntry>, String>((ref, goalId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.savingsEntries)
        ..where((e) => e.goalId.equals(goalId))
        ..orderBy([(e) => OrderingTerm.desc(e.date)]))
      .watch();
});
