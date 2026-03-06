import 'package:anotagasto_app/core/http/http_client.dart';
import 'package:anotagasto_app/core/models/analytics_daily_model.dart';
import 'package:anotagasto_app/core/models/analytics_summary_model.dart';

class AnalyticsRepository {
  final HttpClient _http;

  AnalyticsRepository(HttpClient http) : _http = http;

  Future<AnalyticsSummaryModel> getSummary(String month) async {
    final response = await _http.get(
      '/analytics/summary',
      queryParams: {'month': month},
    );
    return AnalyticsSummaryModel.fromJson(response.data);
  }

  Future<AnalyticsDailyModel> getDaily(String month) async {
    final response = await _http.get(
      '/analytics/daily',
      queryParams: {'month': month},
    );
    return AnalyticsDailyModel.fromJson(response.data);
  }
}
