class UserModel {
  final int id;
  final String username;
  final String deviceToken;
  final int isActive;
  final int tokens;

  UserModel({
    required this.id,
    required this.username,
    required this.deviceToken,
    required this.isActive,
    required this.tokens,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      deviceToken: json['device_token'],
      isActive: json['is_active'],
      tokens: json['tokens'],
    );
  }
}
