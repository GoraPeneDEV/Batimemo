/// Simple user model for leave management
class SimpleUser {
  final int id;
  final String name;
  final String? firstName;
  final String? lastName;
  final String? profileImage;

  SimpleUser({
    required this.id,
    required this.name,
    this.firstName,
    this.lastName,
    this.profileImage,
  });

  factory SimpleUser.fromJson(Map<String, dynamic> json) {
    return SimpleUser(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      name: json['name'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      profileImage: json['profileImage'] ?? json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'profileImage': profileImage,
    };
  }
}
