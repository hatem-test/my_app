/// أدوار المستخدمين في النظام
enum UserRole {
  mother,
  teacher,
  admin,
}

/// نموذج المستخدم الأساسي
/// يُستخدم لتمثيل جميع المستخدمين في النظام (أمهات، معلمات، مدراء)
class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final UserRole role;
  final String? profileImageUrl;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    required this.role,
    this.profileImageUrl,
    this.isVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  /// إنشاء نموذج من استجابة Supabase JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      role: _parseRole(json['role']),
      profileImageUrl: json['profile_image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// تحويل النموذج إلى JSON للإرسال إلى Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role.name,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// تحويل للإدراج (بدون id و timestamps)
  Map<String, dynamic> toInsertJson() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'role': role.name,
      'profile_image_url': profileImageUrl,
    };
  }

  /// إنشاء نسخة معدلة من النموذج
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    UserRole? role,
    String? profileImageUrl,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// تحليل الدور من النص
  static UserRole _parseRole(dynamic role) {
    if (role is String) {
      return UserRole.values.firstWhere(
        (e) => e.name == role,
        orElse: () => UserRole.mother,
      );
    }
    return UserRole.mother;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserModel(id: $id, name: $name, role: ${role.name})';
}
