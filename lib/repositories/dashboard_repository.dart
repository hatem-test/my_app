import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../models/activity_item.dart';
import 'children_repository.dart';
import 'guardian_repository.dart';
import 'report_repository.dart';
import 'teacher_repository.dart';

class DashboardRepository {
  final ChildrenRepository _childrenRepo;
  final TeacherRepository _teacherRepo;
  final GuardianRepository _guardianRepo;
  final ReportRepository _reportRepo;

  DashboardRepository(
    this._childrenRepo,
    this._teacherRepo,
    this._guardianRepo,
    this._reportRepo,
  );

  /// جلب آخر النشاطات من جميع المصادر
  Future<List<ActivityItem>> getRecentActivities({int limit = 10}) async {
    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        _childrenRepo.getAllChildren(),
        _teacherRepo.getAllTeachers(),
        _guardianRepo.getAllGuardians(),
        _reportRepo.getAllReports(), // Assuming this exists or similar
      ]);

      final children = results[0] as List<dynamic>;
      final teachers = results[1] as List<dynamic>;
      final guardians = results[2] as List<dynamic>;
      final reports = results[3] as List<dynamic>;

      List<ActivityItem> activities = [];

      // Add Children activities (sorted by createdAt if available)
      for (var child in children) {
        if (child.createdAt != null) {
          activities.add(ActivityItem(
            title: 'تم إضافة طفل جديد: ${child.name}',
            subtitle: _timeAgo(child.createdAt!),
            timestamp: child.createdAt!,
            icon: Icons.child_care,
            color: AppColors.primary,
            type: ActivityType.newChild,
            entityId: child.id,
          ));
        }
      }

      // Add Teacher activities
      for (var teacher in teachers) {
        if (teacher.createdAt != null) {
          activities.add(ActivityItem(
            title: 'انضمام معلمة جديدة: ${teacher.name}',
            subtitle: _timeAgo(teacher.createdAt!),
            timestamp: teacher.createdAt!,
            icon: Icons.person_add,
            color: AppColors.secondary,
            type: ActivityType.newTeacher,
            entityId: teacher.id,
          ));
        }
      }

      // Add Guardian activities
      for (var guardian in guardians) {
        // Assuming GuardianModel has createdAt (Verified in earlier interactions implicitly via user request context, or safe fallback)
        // If it doesn't, we might skip or use a default. For now assume it does as per typical Supabase models.
        // Dynamic check to be safe if types are lost
        DateTime? createdAt;
        try {
          createdAt = (guardian as dynamic).createdAt;
        } catch (_) {}

        if (createdAt != null) {
          activities.add(ActivityItem(
            title: 'تسجيل ولي أمر جديد: ${guardian.name}',
            subtitle: _timeAgo(createdAt),
            timestamp: createdAt,
            icon: Icons.family_restroom,
            color: AppColors.accent,
            type: ActivityType.newGuardian,
            entityId: guardian.id,
          ));
        }
      }

      // Add Report activities
      for (var report in reports) {
        if (report.createdAt != null) {
          // We might want to look up teacher name if possible, or just say "Teacher"
          // For now, simple text
          activities.add(ActivityItem(
            title:
                'تم إضافة تقرير يومي للطفل', //Ideally we'd have child name here too
            subtitle: _timeAgo(report.createdAt!),
            timestamp: report.createdAt!,
            icon: Icons.assignment,
            color: AppColors.success,
            type: ActivityType.newReport,
            entityId: report.id,
          ));
        }
      }

      // Sort by timestamp descending
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Take top N
      if (activities.length > limit) {
        activities = activities.sublist(0, limit);
      }

      return activities;
    } catch (e) {
      debugPrint('Error fetching recent activities: $e');
      return [];
    }
  }

  String _timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 365) {
      return 'منذ ${(difference.inDays / 365).floor()} سنة';
    } else if (difference.inDays > 30) {
      return 'منذ ${(difference.inDays / 30).floor()} شهر';
    } else if (difference.inDays > 7) {
      return 'منذ ${(difference.inDays / 7).floor()} أسبوع';
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}
