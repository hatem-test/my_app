import 'user_model.dart';

/// نموذج المعلمة
/// يُستخدم لتمثيل بيانات المعلمة في الحضانة
class TeacherModel {
  final String id;
  final String userId;
  final String? specialization;
  final DateTime? hireDate;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// بيانات المستخدم المرتبطة (للعلاقات المتداخلة)
  final UserModel? user;

  const TeacherModel({
    required this.id,
    required this.userId,
    this.specialization,
    this.hireDate,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  /// الحصول على اسم المعلمة
  String get name => user?.name ?? '';

  /// الحصول على البريد الإلكتروني
  String get email => user?.email ?? '';

  /// الحصول على رقم الهاتف
  String get phone => user?.phone ?? '';

  /// الحصول على نص التخصص
  String get specializationText => specialization ?? 'معلمة صف';

  /// إنشاء نموذج من استجابة Supabase JSON
  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      specialization: json['specialization'] as String?,
      hireDate: json['hire_date'] != null
          ? DateTime.parse(json['hire_date'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      user: json['users'] != null
          ? UserModel.fromJson(json['users'] as Map<String, dynamic>)
          : null,
    );
  }

  /// تحويل النموذج إلى JSON للإرسال إلى Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'specialization': specialization,
      'hire_date': hireDate?.toIso8601String().split('T').first,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// تحويل للإدراج (بدون id و timestamps)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'specialization': specialization,
      'hire_date': hireDate?.toIso8601String().split('T').first,
      'is_active': isActive,
    };
  }

  /// إنشاء نسخة معدلة من النموذج
  TeacherModel copyWith({
    String? id,
    String? userId,
    String? specialization,
    DateTime? hireDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserModel? user,
  }) {
    return TeacherModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      specialization: specialization ?? this.specialization,
      hireDate: hireDate ?? this.hireDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeacherModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'TeacherModel(id: $id, name: $name, specialization: $specializationText)';
}
