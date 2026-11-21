import '../../data/database/app_database.dart';

int walletBalance(Wallet wallet, List<Transaction> transactions) {
  var balance = wallet.initialBalance;
  for (final tx in transactions) {
    if (tx.type == 'income' && tx.walletId == wallet.id) balance += tx.amount;
    if (tx.type == 'expense' && tx.walletId == wallet.id) balance -= tx.amount;
    if (tx.type == 'transfer' && tx.walletId == wallet.id) balance -= tx.amount;
    if (tx.type == 'transfer' && tx.toWalletId == wallet.id) balance += tx.amount;
  }
  return balance;
}

int totalBalance(List<Wallet> wallets, List<Transaction> transactions) {
  return wallets.fold<int>(0, (sum, w) => sum + walletBalance(w, transactions));
}
