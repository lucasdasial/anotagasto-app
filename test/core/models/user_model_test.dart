import 'package:anotagasto_app/core/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserModel.fromJson', () {
    test('parses all fields from response with data wrapper', () {
      final model = UserModel.fromJson({
        'data': {'id': 'abc-123', 'name': 'João Silva', 'phone': '11999999999'},
      });

      expect(model.id, 'abc-123');
      expect(model.name, 'João Silva');
      expect(model.phone, '11999999999');
    });

    test('parses all fields from response without data wrapper', () {
      final model = UserModel.fromJson({
        'id': 'abc-123',
        'name': 'João Silva',
        'phone': '11999999999',
      });

      expect(model.id, 'abc-123');
      expect(model.name, 'João Silva');
      expect(model.phone, '11999999999');
    });

    test('converts non-string id to string', () {
      final model = UserModel.fromJson({
        'data': {'id': 42, 'name': 'João', 'phone': '11999999999'},
      });

      expect(model.id, '42');
    });

    test('returns empty string for missing name', () {
      final model = UserModel.fromJson({'data': {'id': 'abc-123'}});

      expect(model.name, '');
    });

    test('returns empty string for missing phone', () {
      final model = UserModel.fromJson({'data': {'id': 'abc-123'}});

      expect(model.phone, '');
    });
  });
}
