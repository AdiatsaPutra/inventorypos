import 'package:intl/intl.dart';

extension CurrencyFormatter on int {
  String toRupiah() {
    final formatter = NumberFormat.currency(
      locale: 'id_ID', // Indonesian locale
      symbol: 'Rp', // Currency symbol
      decimalDigits: 0, // No decimal places
    );
    return formatter.format(this);
  }
}
