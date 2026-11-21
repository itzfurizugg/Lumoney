import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

class TransactionRepository {
  TransactionRepository(this.db);
  final AppDatabase db;
  static const _uuid = Uuid();

  Future<void> create({
    required String type,
    required String title,
    required int amount,
    required String walletId,
    String? toWalletId,
    String? categoryId,
    required DateTime date,
    String note = '',
    String? attachmentPath,
  }) async {
    await db.into(db.transactions).insert(TransactionsCompanion.insert(
          id: _uuid.v4(),
          type: type,
          title: Value(title),
          amount: amount,
          walletId: walletId,
          toWalletId: Value(toWalletId),
          categoryId: Value(categoryId),
          date: date,
          note: Value(note),
          attachmentPath: Value(attachmentPath),
          createdAt: DateTime.now(),
        ));
  }

  Future<void> updateTransaction(
    Transaction tx, {
    String? type,
    String? title,
    int? amount,
    String? walletId,
    String? toWalletId,
    bool clearToWalletId = false,
    String? categoryId,
    bool clearCategoryId = false,
    DateTime? date,
    String? note,
    String? attachmentPath,
    bool clearAttachmentPath = false,
  }) async {
    await (db.update(db.transactions)..where((t) => t.id.equals(tx.id))).write(TransactionsCompanion(
      type: type != null ? Value(type) : const Value.absent(),
      title: title != null ? Value(title) : const Value.absent(),
      amount: amount != null ? Value(amount) : const Value.absent(),
      walletId: walletId != null ? Value(walletId) : const Value.absent(),
      toWalletId: clearToWalletId ? const Value(null) : (toWalletId != null ? Value(toWalletId) : const Value.absent()),
      categoryId: clearCategoryId ? const Value(null) : (categoryId != null ? Value(categoryId) : const Value.absent()),
      date: date != null ? Value(date) : const Value.absent(),
      note: note != null ? Value(note) : const Value.absent(),
      attachmentPath: clearAttachmentPath ? const Value(null) : (attachmentPath != null ? Value(attachmentPath) : const Value.absent()),
    ));
  }

  Future<void> deleteTransaction(String id) async {
    await (db.delete(db.transactions)..where((t) => t.id.equals(id))).go();
  }
}
