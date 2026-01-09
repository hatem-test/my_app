import 'user_model.dart';

/// نموذج ولي الأمر (الأم/الأب)
/// يُستخدم لتمثيل بيانات ولي أمر الطفل
class GuardianModel {
  final String id;
  final String userId;
  final String? address;
  final String? emergencyPhone;
  final String relationship;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// بيانات المستخدم المرتبطة (للعلاقات المتداخلة)
  final UserModel? user;

  const GuardianModel({
    required this.id,
    required this.userId,
    this.address,
    this.emergencyPhone,
    this.relationship = 'أم',
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  /// الحصول على اسم ولي الأمر
  String get name => user?.name ?? '';

  /// الحصول على البريد الإلكتروني
  String get email => user?.email ?? '';

  /// الحصول على رقم الهاتف
  String get phone => user?.phone ?? emergencyPhone ?? '';

  /// إنشاء نموذج من استجابة Supabase JSON
  factory GuardianModel.fromJson(Map<String, dynamic> json) {
    return GuardianModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      address: json['address'] as String?,
      emergencyPhone: json['emergency_phone'] as String?,
      relationship: json['relationship'] as String? ?? 'أم',
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
      'address': address,
      'emergency_phone': emergencyPhone,
      'relationship': relationship,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// تحويل للإدراج (بدون id و timestamps)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'address': address,
      'emergency_phone': emergencyPhone,
      'relationship': relationship,
    };
  }

  /// إنشاء نسخة معدلة من النموذج
  GuardianModel copyWith({
    String? id,
    String? userId,
    String? address,
    String? emergencyPhone,
    String? relationship,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserModel? user,
  }) {
    return GuardianModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      address: address ?? this.address,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      relationship: relationship ?? this.relationship,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuardianModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'GuardianModel(id: $id, name: $name, relationship: $relationship)';
}
