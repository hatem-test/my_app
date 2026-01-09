/// جنس الطفل
enum Gender {
  boy,
  girl,
}

/// نموذج الطفل
/// يُستخدم لتمثيل بيانات الطفل المسجل في الحضانة
class ChildModel {
  final String id;
  final String guardianId;
  final String? teacherId;
  final String name;
  final DateTime birthDate;
  final Gender gender;
  final String? imageUrl;
  final List<String>? allergies;
  final String? className;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ChildModel({
    required this.id,
    required this.guardianId,
    this.teacherId,
    required this.name,
    required this.birthDate,
    required this.gender,
    this.imageUrl,
    this.allergies,
    this.className,
    this.createdAt,
    this.updatedAt,
  });

  /// حساب عمر الطفل
  int get age {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      years--;
    }
    return years;
  }

  /// الحصول على نص العمر بالعربية
  String get ageText => '$age سنوات';

  /// الحصول على نص الجنس بالعربية
  String get genderText => gender == Gender.boy ? 'ذكر' : 'أنثى';

  /// الحصول على مسار الصورة الافتراضية
  String get defaultImagePath =>
      gender == Gender.boy ? 'assets/images/boy.png' : 'assets/images/girl.png';

  /// إنشاء نموذج من استجابة Supabase JSON
  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['id'] as String,
      guardianId: json['guardian_id'] as String,
      teacherId: json['teacher_id'] as String?,
      name: json['name'] as String,
      birthDate: DateTime.parse(json['birth_date'] as String),
      gender: _parseGender(json['gender']),
      imageUrl: json['image_url'] as String?,
      allergies: json['allergies'] != null
          ? List<String>.from(json['allergies'] as List)
          : null,
      className: json['class_name'] as String?,
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
      'guardian_id': guardianId,
      'teacher_id': teacherId,
      'name': name,
      'birth_date': birthDate.toIso8601String().split('T').first,
      'gender': gender.name,
      'image_url': imageUrl,
      'allergies': allergies,
      'class_name': className,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// تحويل للإدراج (بدون id و timestamps)
  Map<String, dynamic> toInsertJson() {
    return {
      'guardian_id': guardianId,
      'teacher_id': teacherId,
      'name': name,
      'birth_date': birthDate.toIso8601String().split('T').first,
      'gender': gender.name,
      'image_url': imageUrl,
      'allergies': allergies,
      'class_name': className,
    };
  }

  /// إنشاء نسخة معدلة من النموذج
  ChildModel copyWith({
    String? id,
    String? guardianId,
    String? teacherId,
    String? name,
    DateTime? birthDate,
    Gender? gender,
    String? imageUrl,
    List<String>? allergies,
    String? className,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChildModel(
      id: id ?? this.id,
      guardianId: guardianId ?? this.guardianId,
      teacherId: teacherId ?? this.teacherId,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      imageUrl: imageUrl ?? this.imageUrl,
      allergies: allergies ?? this.allergies,
      className: className ?? this.className,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// تحليل الجنس من النص
  static Gender _parseGender(dynamic gender) {
    if (gender is String) {
      return Gender.values.firstWhere(
        (e) => e.name == gender,
        orElse: () => Gender.boy,
      );
    }
    return Gender.boy;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChildModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ChildModel(id: $id, name: $name, age: $age)';
}
