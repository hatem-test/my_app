/// حالة الحضور
enum AttendanceStatus {
  present, // حاضر
  absent, // غائب
  late, // متأخر
  leftEarly, // انصراف مبكر
}

/// نموذج الحضور والانصراف
/// يُستخدم لتتبع وصول ومغادرة الأطفال
class AttendanceModel {
  final String id;
  final String childId;
  final String recordedBy;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final AttendanceStatus status;
  final DateTime attendanceDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AttendanceModel({
    required this.id,
    required this.childId,
    required this.recordedBy,
    this.checkIn,
    this.checkOut,
    required this.status,
    required this.attendanceDate,
    this.createdAt,
    this.updatedAt,
  });

  /// الحصول على نص الحالة بالعربية
  String get statusText {
    switch (status) {
      case AttendanceStatus.present:
        return 'حاضر';
      case AttendanceStatus.absent:
        return 'غائب';
      case AttendanceStatus.late:
        return 'متأخر';
      case AttendanceStatus.leftEarly:
        return 'انصراف مبكر';
    }
  }

  /// الحصول على وقت الوصول المنسق
  String get checkInText {
    if (checkIn == null) return '-';
    return '${checkIn!.hour.toString().padLeft(2, '0')}:${checkIn!.minute.toString().padLeft(2, '0')}';
  }

  /// الحصول على وقت المغادرة المنسق
  String get checkOutText {
    if (checkOut == null) return '-';
    return '${checkOut!.hour.toString().padLeft(2, '0')}:${checkOut!.minute.toString().padLeft(2, '0')}';
  }

  /// التحقق هل الطفل موجود حالياً
  bool get isCurrentlyPresent => checkIn != null && checkOut == null;

  /// إنشاء نموذج من استجابة Supabase JSON
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      recordedBy: json['recorded_by'] as String,
      checkIn: json['check_in'] != null
          ? DateTime.parse(json['check_in'] as String)
          : null,
      checkOut: json['check_out'] != null
          ? DateTime.parse(json['check_out'] as String)
          : null,
      status: _parseStatus(json['status']),
      attendanceDate: DateTime.parse(json['attendance_date'] as String),
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
      'recorded_by': recordedBy,
      'check_in': checkIn?.toIso8601String(),
      'check_out': checkOut?.toIso8601String(),
      'status': status.name,
      'attendance_date': attendanceDate.toIso8601String().split('T').first,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// تحويل للإدراج (بدون id و timestamps)
  Map<String, dynamic> toInsertJson() {
    return {
      'child_id': childId,
      'recorded_by': recordedBy,
      'check_in': checkIn?.toIso8601String(),
      'check_out': checkOut?.toIso8601String(),
      'status': status.name,
      'attendance_date': attendanceDate.toIso8601String().split('T').first,
    };
  }

  /// إنشاء نسخة معدلة من النموذج
  AttendanceModel copyWith({
    String? id,
    String? childId,
    String? recordedBy,
    DateTime? checkIn,
    DateTime? checkOut,
    AttendanceStatus? status,
    DateTime? attendanceDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      recordedBy: recordedBy ?? this.recordedBy,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      status: status ?? this.status,
      attendanceDate: attendanceDate ?? this.attendanceDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// تحليل الحالة من النص
  static AttendanceStatus _parseStatus(dynamic status) {
    if (status is String) {
      return AttendanceStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => AttendanceStatus.present,
      );
    }
    return AttendanceStatus.present;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AttendanceModel(id: $id, childId: $childId, status: $statusText)';
}
