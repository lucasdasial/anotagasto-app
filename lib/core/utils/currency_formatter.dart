import 'package:intl/intl.dart';

abstract final class CurrencyFormatter {
  static final NumberFormat _fmt = NumberFormat.simpleCurrency(
    locale: 'pt_BR',
    name: 'BRL',
  );

  /// Recebe centavos (int) e retorna string formatada em BRL.
  /// Ex: 1000 → "R$ 10,00"
  static String format(num cents) => _fmt.format(cents / 100);

  /// Recebe string BRL e retorna centavos (int).
  /// Ex: "R$ 10,00" → 1000
  static int? parse(String value) {
    try {
      final reais = _fmt.parse(value.replaceAll(' ', '')).toDouble();
      return (reais * 100).round();
    } catch (_) {
      final cleaned = value.replaceAll(RegExp(r'[^\d,.]'), '').replaceAll(',', '.');
      final d = double.tryParse(cleaned);
      return d != null ? (d * 100).round() : null;
    }
  }
}
