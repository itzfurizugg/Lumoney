import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

class WalletRepository {
  WalletRepository(this.db);
  final AppDatabase db;
  static const _uuid = Uuid();

  Future<void> create({
    required String name,
    required String icon,
    required int color,
    required int initialBalance,
  }) async {
    await db.into(db.wallets).insert(WalletsCompanion.insert(
          id: _uuid.v4(),
          name: name,
          icon: Value(icon),
          color: Value(color),
          initialBalance: Value(initialBalance),
          createdAt: DateTime.now(),
        ));
  }

  Future<void> updateWallet(Wallet wallet, {String? name, String? icon, int? color, int? initialBalance, bool? isArchived}) async {
    await (db.update(db.wallets)..where((w) => w.id.equals(wallet.id))).write(WalletsCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      icon: icon != null ? Value(icon) : const Value.absent(),
      color: color != null ? Value(color) : const Value.absent(),
      initialBalance: initialBalance != null ? Value(initialBalance) : const Value.absent(),
      isArchived: isArchived != null ? Value(isArchived) : const Value.absent(),
    ));
  }

  Future<void> deleteWallet(String id) async {
    await (db.delete(db.wallets)..where((w) => w.id.equals(id))).go();
  }
}
