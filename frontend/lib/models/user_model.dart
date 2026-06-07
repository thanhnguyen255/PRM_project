class UserModel {
  final int id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String role;

  UserModel({required this.id, required this.email, required this.fullName, this.avatarUrl, required this.role});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id:        json['id'],
    email:     json['email'],
    fullName:  json['fullName'],
    avatarUrl: json['avatarUrl'],
    role:      json['role'],
  );
}
