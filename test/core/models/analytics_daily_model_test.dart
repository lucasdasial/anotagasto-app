import 'package:anotagasto_app/core/models/analytics_daily_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DayStat.fromJson', () {
    test('extracts day number from date string', () {
      final stat = DayStat.fromJson({'date': '2024-03-15', 'total': 1000});

      expect(stat.day, 15);
      expect(stat.total, 1000);
    });

    test('returns day 0 for empty date string', () {
      final stat = DayStat.fromJson({'date': '', 'total': 500});

      expect(stat.day, 0);
    });

    test('returns total 0 when total is missing', () {
      final stat = DayStat.fromJson({'date': '2024-03-10'});

      expect(stat.total, 0);
    });

    test('converts num total to int', () {
      final stat = DayStat.fromJson({'date': '2024-03-01', 'total': 250.0});

      expect(stat.total, 250);
      expect(stat.total, isA<int>());
    });
  });

  group('AnalyticsDailyModel.fromJson', () {
    test('parses days list from data wrapper', () {
      final model = AnalyticsDailyModel.fromJson({
        'data': {
          'days': [
            {'date': '2024-03-01', 'total': 1000},
            {'date': '2024-03-02', 'total': 2000},
          ],
        },
      });

      expect(model.daily.length, 2);
      expect(model.daily[0].day, 1);
      expect(model.daily[0].total, 1000);
      expect(model.daily[1].day, 2);
      expect(model.daily[1].total, 2000);
    });

    test('parses days list without data wrapper', () {
      final model = AnalyticsDailyModel.fromJson({
        'days': [
          {'date': '2024-03-05', 'total': 500},
        ],
      });

      expect(model.daily.length, 1);
      expect(model.daily[0].day, 5);
    });

    test('returns empty list for empty input', () {
      final model = AnalyticsDailyModel.fromJson({});

      expect(model.daily, isEmpty);
    });
  });
}
