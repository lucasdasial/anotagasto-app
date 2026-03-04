class DayStat {
  final int day;
  final double total;

  const DayStat({required this.day, required this.total});

  factory DayStat.fromJson(Map<String, dynamic> json) {
    return DayStat(
      day: json['day'] as int? ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AnalyticsDailyModel {
  final List<DayStat> daily;

  const AnalyticsDailyModel({required this.daily});

  factory AnalyticsDailyModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final days = data['daily'] as List? ?? [];
    return AnalyticsDailyModel(
      daily: days.map((e) => DayStat.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
