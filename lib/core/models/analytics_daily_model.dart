class DayStat {
  final int day;
  final int total;

  const DayStat({required this.day, required this.total});

  factory DayStat.fromJson(Map<String, dynamic> json) {
    // API returns full date string (e.g. "2024-03-15"); extract the day number.
    final dateStr = json['date'] as String? ?? '';
    final day = dateStr.isNotEmpty ? DateTime.parse(dateStr).day : 0;
    return DayStat(
      day: day,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

class AnalyticsDailyModel {
  final List<DayStat> daily;

  const AnalyticsDailyModel({required this.daily});

  factory AnalyticsDailyModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final days = data['days'] as List? ?? [];
    return AnalyticsDailyModel(
      daily: days.map((e) => DayStat.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
