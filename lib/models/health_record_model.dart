/// نوع السجل الصحي
enum HealthRecordType {
  checkup, // فحص دوري
  vaccination, // تطعيم
  note, // ملاحظة صحية
}

/// نموذج السجل الصحي
/// يُستخدم لتتبع الحالة الصحية، التطعيمات، والفحوصات الدورية للطفل
class HealthRecordModel {
  final String id;
  final String childId;
  final String generalStatus;
  final String? temperature;
  final String? vaccinations;
  final String title;
  final String? description;
  final HealthRecordType recordType;
  final DateTime recordDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const HealthRecordModel({
    required this.id,
    required this.childId,
    required this.generalStatus,
    this.temperature,
    this.vaccinations,
    required this.title,
    this.description,
    required this.recordType,
    required this.recordDate,
    this.createdAt,
    this.updatedAt,
  });

  /// الحصول على نص نوع السجل بالعربية
  String get recordTypeText {
    switch (recordType) {
      case HealthRecordType.checkup:
        return 'فحص دوري';
      case HealthRecordType.vaccination:
        return 'تطعيم';
      case HealthRecordType.note:
        return 'ملاحظة صحية';
    }
  }

  /// إنشاء نموذج من استجابة Supabase JSON
  factory HealthRecordModel.fromJson(Map<String, dynamic> json) {
    return HealthRecordModel(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      generalStatus: json['general_status'] as String,
      temperature: json['temperature'] as String?,
      vaccinations: json['vaccinations'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      recordType: _parseRecordType(json['record_type']),
      recordDate: DateTime.parse(json['record_date'] as String),
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
      'general_status': generalStatus,
      'temperature': temperature,
      'vaccinations': vaccinations,
      'title': title,
      'description': description,
      'record_type': recordType.name,
      'record_date': recordDate.toIso8601String().split('T').first,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// تحويل للإدراج (بدون id و timestamps)
  Map<String, dynamic> toInsertJson() {
    return {
      'child_id': childId,
      'general_status': generalStatus,
      'temperature': temperature,
      'vaccinations': vaccinations,
      'title': title,
      'description': description,
      'record_type': recordType.name,
      'record_date': recordDate.toIso8601String().split('T').first,
    };
  }

  /// إنشاء نسخة معدلة من النموذج
  HealthRecordModel copyWith({
    String? id,
    String? childId,
    String? generalStatus,
    String? temperature,
    String? vaccinations,
    String? title,
    String? description,
    HealthRecordType? recordType,
    DateTime? recordDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthRecordModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      generalStatus: generalStatus ?? this.generalStatus,
      temperature: temperature ?? this.temperature,
      vaccinations: vaccinations ?? this.vaccinations,
      title: title ?? this.title,
      description: description ?? this.description,
      recordType: recordType ?? this.recordType,
      recordDate: recordDate ?? this.recordDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// تحليل نوع السجل من النص
  static HealthRecordType _parseRecordType(dynamic type) {
    if (type is String) {
      return HealthRecordType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => HealthRecordType.checkup,
      );
    }
    return HealthRecordType.checkup;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthRecordModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'HealthRecordModel(id: $id, title: $title, type: $recordTypeText)';
}
