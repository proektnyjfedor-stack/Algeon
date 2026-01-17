/// Модель пользователя

class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final int? grade;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.grade,
    required this.createdAt,
  });

  /// Из JSON
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      grade: json['grade'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// В JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'grade': grade,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Из Firebase (для будущего)
  factory AppUser.fromFirebase(dynamic firebaseUser) {
    return AppUser(
      uid: firebaseUser.uid as String,
      email: firebaseUser.email as String? ?? '',
      displayName: firebaseUser.displayName as String?,
      grade: null,
      createdAt: DateTime.now(),
    );
  }

  /// Копия с изменениями
  AppUser copyWith({
    String? displayName,
    int? grade,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      grade: grade ?? this.grade,
      createdAt: createdAt,
    );
  }

  @override
  String toString() {
    return 'AppUser(uid: $uid, email: $email, grade: $grade)';
  }
}
