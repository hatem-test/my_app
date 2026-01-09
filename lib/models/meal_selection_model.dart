import 'meal_model.dart';

/// نموذج اختيار الوجبة
/// يُستخدم لتمثيل اختيار ولي الأمر لوجبة معينة لطفله
class MealSelectionModel {
  final String id;
  final String childId;
  final String mealId;
  final String selectedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// بيانات الوجبة المرتبطة (لالعلاقات المتداخلة)
  final MealModel? meal;

  const MealSelectionModel({
    required this.id,
    required this.childId,
    required this.mealId,
    required this.selectedBy,
    this.createdAt,
    this.updatedAt,
    this.meal,
  });

  /// إنشاء نموذج من استجابة Supabase JSON
  factory MealSelectionModel.fromJson(Map<String, dynamic> json) {
    return MealSelectionModel(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      mealId: json['meal_id'] as String,
      selectedBy: json['selected_by'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      meal: json['meals'] != null
          ? MealModel.fromJson(json['meals'] as Map<String, dynamic>)
          : null,
    );
  }

  /// تحويل النموذج إلى JSON للإرسال إلى Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'meal_id': mealId,
      'selected_by': selectedBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// تحويل للإدراج (بدون id و timestamps)
  Map<String, dynamic> toInsertJson() {
    return {
      'child_id': childId,
      'meal_id': mealId,
      'selected_by': selectedBy,
    };
  }

  /// إنشاء نسخة معدلة من النموذج
  MealSelectionModel copyWith({
    String? id,
    String? childId,
    String? mealId,
    String? selectedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    MealModel? meal,
  }) {
    return MealSelectionModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      mealId: mealId ?? this.mealId,
      selectedBy: selectedBy ?? this.selectedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      meal: meal ?? this.meal,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealSelectionModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MealSelectionModel(id: $id, childId: $childId, mealId: $mealId)';
}
