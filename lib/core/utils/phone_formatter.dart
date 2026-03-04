import 'package:flutter/services.dart';

class PhoneMaskFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final masked = _applyMask(digits);
    return newValue.copyWith(
      text: masked,
      selection: TextSelection.collapsed(offset: masked.length),
    );
  }

  static String _applyMask(String digits) {
    if (digits.isEmpty) return '';
    // Limita a 11 dígitos (celular com DDD)
    final d = digits.length > 11 ? digits.substring(0, 11) : digits;
    final buf = StringBuffer();
    for (int i = 0; i < d.length; i++) {
      if (i == 0) buf.write('(');
      if (i == 2) buf.write(') ');
      // Celular (11 dígitos): traço na posição 7 → (XX) XXXXX-XXXX
      // Fixo   (10 dígitos): traço na posição 6 → (XX) XXXX-XXXX
      if (i == (d.length == 11 ? 7 : 6)) buf.write('-');
      buf.write(d[i]);
    }
    return buf.toString();
  }

  /// Remove a máscara, retornando apenas os dígitos para enviar à API.
  static String unmasked(String value) => value.replaceAll(RegExp(r'\D'), '');
}
