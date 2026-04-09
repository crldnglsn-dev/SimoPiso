import 'package:intl/intl.dart';

final NumberFormat _pesoFormatter = NumberFormat.currency(
  locale: 'en_PH',
  symbol: 'PHP ',
  decimalDigits: 0,
);

final NumberFormat _compactPesoFormatter = NumberFormat.compactCurrency(
  locale: 'en_PH',
  symbol: 'PHP ',
  decimalDigits: 1,
);

String formatPhp(num value) => _pesoFormatter.format(value);

String formatCompactPhp(num value) => _compactPesoFormatter.format(value);
