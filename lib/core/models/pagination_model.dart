class PaginationModel {
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  const PaginationModel({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  factory PaginationModel.fromMap(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }

  bool get hasNextPage => page < totalPages;
}
