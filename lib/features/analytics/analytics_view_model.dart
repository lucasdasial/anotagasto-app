import 'package:anotagasto_app/core/models/analytics_daily_model.dart';
import 'package:anotagasto_app/core/models/analytics_summary_model.dart';
import 'package:anotagasto_app/core/utils/date_formatter.dart';
import 'package:anotagasto_app/core/view_state.dart';
import 'package:anotagasto_app/features/analytics/analytics_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AnalyticsData {
  final AnalyticsSummaryModel summary;
  final AnalyticsDailyModel daily;

  const AnalyticsData({required this.summary, required this.daily});
}

class AnalyticsViewModel extends ChangeNotifier {
  final AnalyticsRepository _repository;

  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime get month => _month;

  bool get canGoNext {
    final now = DateTime.now();
    return _month.year < now.year ||
        (_month.year == now.year && _month.month < now.month);
  }

  ViewState viewState = InitialStateView();

  AnalyticsViewModel(this._repository);

  Future<void> load() async {
    viewState = LoadingStateView();
    notifyListeners();

    try {
      final monthStr = DateFormatter.toApiMonth(_month.year, _month.month);
      final results = await Future.wait([
        _repository.getSummary(monthStr),
        _repository.getDaily(monthStr),
      ]);
      viewState = SuccessStateView(AnalyticsData(
        summary: results[0] as AnalyticsSummaryModel,
        daily: results[1] as AnalyticsDailyModel,
      ));
    } on DioException catch (e) {
      viewState = ErrorStateView(e.message ?? 'Erro ao carregar análises.');
    } catch (e, stack) {
      debugPrint('AnalyticsViewModel.load: $e\n$stack');
      viewState = ErrorStateView('Ocorreu um erro inesperado. Tente novamente.');
    }

    notifyListeners();
  }

  void previousMonth() {
    _month = DateTime(_month.year, _month.month - 1);
    load();
  }

  void nextMonth() {
    if (!canGoNext) return;
    _month = DateTime(_month.year, _month.month + 1);
    load();
  }
}
