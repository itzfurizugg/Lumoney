import 'package:drift/drift.dart';

class Wallets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get icon => text().withDefault(const Constant('account_balance_wallet'))();
  IntColumn get color => integer().withDefault(const Constant(0xFF1565C0))();
  IntColumn get initialBalance => integer().withDefault(const Constant(0))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // income, expense
  TextColumn get icon => text().withDefault(const Constant('category'))();
  IntColumn get color => integer().withDefault(const Constant(0xFF757575))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()(); // income, expense, transfer
  TextColumn get title => text().withDefault(const Constant(''))();
  IntColumn get amount => integer()();
  TextColumn get walletId => text().references(Wallets, #id)();
  TextColumn get toWalletId => text().nullable().references(Wallets, #id)();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get attachmentPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class SavingsGoals extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get purpose => text().withDefault(const Constant(''))();
  IntColumn get targetAmount => integer()();
  DateTimeColumn get deadline => dateTime().nullable()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))(); // active, achieved, archived
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class SavingsEntries extends Table {
  TextColumn get id => text()();
  TextColumn get goalId => text().references(SavingsGoals, #id)();
  IntColumn get amount => integer()(); // positive deposit, negative withdrawal
  DateTimeColumn get date => dateTime()();
  TextColumn get walletId => text().nullable().references(Wallets, #id)();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
