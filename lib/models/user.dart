/// Модель пользователя

class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final int? grade;
  final String? avatar;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.grade,
    this.avatar,
    required this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String,
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String?,
      grade: json['grade'] as int?,
      avatar: json['avatar'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'grade': grade,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  AppUser copyWith({
    String? displayName,
    int? grade,
    String? avatar,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      grade: grade ?? this.grade,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt,
    );
  }

  @override
  String toString() => 'AppUser(uid: $uid, grade: $grade)';
}
