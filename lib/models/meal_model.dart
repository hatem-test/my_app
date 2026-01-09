/// نوع الوجبة
enum MealType {
  breakfast, // فطور
  snack, // وجبة خفيفة
  lunch, // غداء
  dinner, // عشاء
}

/// نموذج الوجبة
/// يُستخدم لتمثيل الوجبات المتاحة في الحضانة
class MealModel {
  final String id;
  final String name;
  final String time;
  final List<String> items;
  final MealType mealType;
  final DateTime mealDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MealModel({
    required this.id,
    required this.name,
    required this.time,
    required this.items,
    required this.mealType,
    required this.mealDate,
    this.createdAt,
    this.updatedAt,
  });

  /// الحصول على نص نوع الوجبة بالعربية
  String get mealTypeText {
    switch (mealType) {
      case MealType.breakfast:
        return 'الفطور';
      case MealType.snack:
        return 'وجبة خفيفة';
      case MealType.lunch:
        return 'الغداء';
      case MealType.dinner:
        return 'العشاء';
    }
  }

  /// الحصول على عناصر الوجبة كنص
  String get itemsText => items.join('، ');

  /// إنشاء نموذج من استجابة Supabase JSON
  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'] as String,
      name: json['name'] as String,
      time: json['time'] as String,
      items: List<String>.from(json['items'] as List),
      mealType: _parseMealType(json['meal_type']),
      mealDate: DateTime.parse(json['meal_date'] as String),
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
      'name': name,
      'time': time,
      'items': items,
      'meal_type': mealType.name,
      'meal_date': mealDate.toIso8601String().split('T').first,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// تحويل للإدراج (بدون id و timestamps)
  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'time': time,
      'items': items,
      'meal_type': mealType.name,
      'meal_date': mealDate.toIso8601String().split('T').first,
    };
  }

  /// إنشاء نسخة معدلة من النموذج
  MealModel copyWith({
    String? id,
    String? name,
    String? time,
    List<String>? items,
    MealType? mealType,
    DateTime? mealDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealModel(
      id: id ?? this.id,
      name: name ?? this.name,
      time: time ?? this.time,
      items: items ?? this.items,
      mealType: mealType ?? this.mealType,
      mealDate: mealDate ?? this.mealDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// تحليل نوع الوجبة من النص
  static MealType _parseMealType(dynamic type) {
    if (type is String) {
      return MealType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => MealType.lunch,
      );
    }
    return MealType.lunch;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MealModel(id: $id, name: $name, type: $mealTypeText)';
}
