/// نموذج التقرير اليومي
/// يُستخدم لتمثيل التقارير اليومية التي تكتبها المعلمة عن الطفل
class ReportModel {
  final String id;
  final String childId;
  final String teacherId;
  final String healthStatus;
  final String activity;
  final String behavior;
  final String sleep;
  final String eating;
  final String? additionalNotes;
  final DateTime reportDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReportModel({
    required this.id,
    required this.childId,
    required this.teacherId,
    required this.healthStatus,
    required this.activity,
    required this.behavior,
    required this.sleep,
    required this.eating,
    this.additionalNotes,
    required this.reportDate,
    this.createdAt,
    this.updatedAt,
  });

  /// إنشاء نموذج من استجابة Supabase JSON
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      teacherId: json['teacher_id'] as String,
      healthStatus: json['health_status'] as String,
      activity: json['activity'] as String,
      behavior: json['behavior'] as String,
      sleep: json['sleep'] as String,
      eating: json['eating'] as String,
      additionalNotes: json['additional_notes'] as String?,
      reportDate: DateTime.parse(json['report_date'] as String),
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
      'child_id': childId,
      'teacher_id': teacherId,
      'health_status': healthStatus,
      'activity': activity,
      'behavior': behavior,
      'sleep': sleep,
      'eating': eating,
      'additional_notes': additionalNotes,
      'report_date': reportDate.toIso8601String().split('T').first,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// تحويل للإدراج (بدون id و timestamps)
  Map<String, dynamic> toInsertJson() {
    return {
      'child_id': childId,
      'teacher_id': teacherId,
      'health_status': healthStatus,
      'activity': activity,
      'behavior': behavior,
      'sleep': sleep,
      'eating': eating,
      'additional_notes': additionalNotes,
      'report_date': reportDate.toIso8601String().split('T').first,
    };
  }

  /// إنشاء نسخة معدلة من النموذج
  ReportModel copyWith({
    String? id,
    String? childId,
    String? teacherId,
    String? healthStatus,
    String? activity,
    String? behavior,
    String? sleep,
    String? eating,
    String? additionalNotes,
    DateTime? reportDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      teacherId: teacherId ?? this.teacherId,
      healthStatus: healthStatus ?? this.healthStatus,
      activity: activity ?? this.activity,
      behavior: behavior ?? this.behavior,
      sleep: sleep ?? this.sleep,
      eating: eating ?? this.eating,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      reportDate: reportDate ?? this.reportDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ReportModel(id: $id, childId: $childId, date: $reportDate)';
}
