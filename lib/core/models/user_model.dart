class UserModel {
  final String id;
  final String name;
  final String phone;

  const UserModel({required this.id, required this.name, required this.phone});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return UserModel(
      id: data['id'].toString(),
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
    );
  }
}
