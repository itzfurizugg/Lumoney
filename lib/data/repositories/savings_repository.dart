import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

class SavingsRepository {
  SavingsRepository(this.db);
  final AppDatabase db;
  static const _uuid = Uuid();

  Future<void> createGoal({
    required String name,
    required String purpose,
    required int targetAmount,
    DateTime? deadline,
    String? imagePath,
  }) async {
    await db.into(db.savingsGoals).insert(SavingsGoalsCompanion.insert(
          id: _uuid.v4(),
          name: name,
          purpose: Value(purpose),
          targetAmount: targetAmount,
          deadline: Value(deadline),
          imagePath: Value(imagePath),
          createdAt: DateTime.now(),
        ));
  }

  Future<void> updateGoal(SavingsGoal goal, {String? name, String? purpose, int? targetAmount, DateTime? deadline, bool clearDeadline = false, String? imagePath, bool clearImage = false, String? status}) async {
    await (db.update(db.savingsGoals)..where((g) => g.id.equals(goal.id))).write(SavingsGoalsCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      purpose: purpose != null ? Value(purpose) : const Value.absent(),
      targetAmount: targetAmount != null ? Value(targetAmount) : const Value.absent(),
      deadline: clearDeadline ? const Value(null) : (deadline != null ? Value(deadline) : const Value.absent()),
      imagePath: clearImage ? const Value(null) : (imagePath != null ? Value(imagePath) : const Value.absent()),
      status: status != null ? Value(status) : const Value.absent(),
    ));
  }

  Future<void> deleteGoal(String id) async {
    await (db.transaction(() async {
      await (db.delete(db.savingsEntries)..where((e) => e.goalId.equals(id))).go();
      await (db.delete(db.savingsGoals)..where((g) => g.id.equals(id))).go();
    }));
  }

  Future<void> addEntry({
    required String goalId,
    required int amount,
    required DateTime date,
    String? walletId,
    String note = '',
  }) async {
    await db.into(db.savingsEntries).insert(SavingsEntriesCompanion.insert(
          id: _uuid.v4(),
          goalId: goalId,
          amount: amount,
          date: date,
          walletId: Value(walletId),
          note: Value(note),
          createdAt: DateTime.now(),
        ));
  }
}
