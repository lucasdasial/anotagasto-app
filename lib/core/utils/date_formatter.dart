import 'package:intl/intl.dart';

abstract final class DateFormatter {
  static final List<String> _monthNames = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  /// Returns "YYYY-MM" string for a given year + month.
  static String toApiMonth(int year, int month) {
    return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
  }

  /// "YYYY-MM" → {year, month}
  static ({int year, int month}) fromApiMonth(String s) {
    final parts = s.split('-');
    return (year: int.parse(parts[0]), month: int.parse(parts[1]));
  }

  /// "Janeiro 2024"
  static String monthLabel(int year, int month) {
    return '${_monthNames[month - 1]} $year';
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM').format(date);
  }

  // coverage:ignore-start
  static String currentMonth() {
    final now = DateTime.now();
    return toApiMonth(now.year, now.month);
  }

  // coverage:ignore-end
}
