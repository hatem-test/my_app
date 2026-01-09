/// نموذج الملاحظات
/// يُستخدم لتمثيل الملاحظات المكتوبة من المعلمة أو ولي الأمر
class NoteModel {
  final String id;
  final String childId;
  final String authorId;
  final String content;
  final bool isSentToParent;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NoteModel({
    required this.id,
    required this.childId,
    required this.authorId,
    required this.content,
    this.isSentToParent = false,
    this.createdAt,
    this.updatedAt,
  });

  /// الحصول على نص الوقت المنسق
  String get timestampText {
    if (createdAt == null) return '';

    final now = DateTime.now();
    final difference = now.difference(createdAt!);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${createdAt!.year}/${createdAt!.month}/${createdAt!.day}';
    }
  }

  /// إنشاء نموذج من استجابة Supabase JSON
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      authorId: json['author_id'] as String,
      content: json['content'] as String,
      isSentToParent: json['is_sent_to_parent'] as bool? ?? false,
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
      'author_id': authorId,
      'content': content,
      'is_sent_to_parent': isSentToParent,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// تحويل للإدراج (بدون id و timestamps)
  Map<String, dynamic> toInsertJson() {
    return {
      'child_id': childId,
      'author_id': authorId,
      'content': content,
      'is_sent_to_parent': isSentToParent,
    };
  }

  /// إنشاء نسخة معدلة من النموذج
  NoteModel copyWith({
    String? id,
    String? childId,
    String? authorId,
    String? content,
    bool? isSentToParent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      isSentToParent: isSentToParent ?? this.isSentToParent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'NoteModel(id: $id, content: ${content.substring(0, content.length > 20 ? 20 : content.length)}...)';
}
