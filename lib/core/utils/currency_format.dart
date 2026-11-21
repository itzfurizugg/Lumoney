import 'package:intl/intl.dart';

class CurrencyFormat {
  CurrencyFormat._();

  static final NumberFormat _idr = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  static String idr(int amount) => _idr.format(amount);

  static String compactIdr(int amount) {
    if (amount.abs() >= 1000000000) {
      return 'Rp${(amount / 1000000000).toStringAsFixed(1)}M';
    }
    if (amount.abs() >= 1000000) {
      return 'Rp${(amount / 1000000).toStringAsFixed(1)}jt';
    }
    if (amount.abs() >= 1000) {
      return 'Rp${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return idr(amount);
  }
}
