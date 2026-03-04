import 'package:intl/intl.dart';

abstract final class CurrencyFormatter {
  static final NumberFormat _fmt = NumberFormat.simpleCurrency(
    locale: 'pt_BR',
    name: 'BRL',
  );

  static String format(num value) => _fmt.format(value);

  static int? parse(String value) {
    try {
      return _fmt.parse(value.replaceAll(' ', '')).toInt();
    } catch (_) {
      final cleaned = value.replaceAll(RegExp(r'[^\d,.]'), '').replaceAll(',', '.');
      final d = double.tryParse(cleaned);
      return d?.toInt();
    }
  }
}
