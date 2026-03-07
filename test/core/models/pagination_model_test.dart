import 'package:anotagasto_app/core/models/pagination_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaginationModel.fromMap', () {
    test('parses all fields correctly', () {
      final model = PaginationModel.fromMap({
        'page': 2,
        'page_size': 10,
        'total': 50,
        'total_pages': 5,
      });

      expect(model.page, 2);
      expect(model.pageSize, 10);
      expect(model.total, 50);
      expect(model.totalPages, 5);
    });

    test('uses default values when fields are missing', () {
      final model = PaginationModel.fromMap({});

      expect(model.page, 1);
      expect(model.pageSize, 20);
      expect(model.total, 0);
      expect(model.totalPages, 1);
    });
  });

  group('hasNextPage', () {
    test('returns true when page is less than totalPages', () {
      const model = PaginationModel(
        page: 1,
        pageSize: 20,
        total: 50,
        totalPages: 3,
      );

      expect(model.hasNextPage, isTrue);
    });

    test('returns false when page equals totalPages', () {
      const model = PaginationModel(
        page: 3,
        pageSize: 20,
        total: 50,
        totalPages: 3,
      );

      expect(model.hasNextPage, isFalse);
    });

    test('returns false when on the only page', () {
      const model = PaginationModel(
        page: 1,
        pageSize: 20,
        total: 5,
        totalPages: 1,
      );

      expect(model.hasNextPage, isFalse);
    });
  });
}
