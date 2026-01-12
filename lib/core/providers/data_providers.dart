import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../repositories/children_repository.dart';
import '../../repositories/attendance_repository.dart';
import '../../repositories/notification_repository.dart';
import '../../repositories/report_repository.dart';
import '../../repositories/guardian_repository.dart';
import '../../repositories/teacher_repository.dart';

class DataProviders {
  static FutureProvider<List<ChildModel>?> childrenProvider(String? teacherId) {
    return FutureProvider<List<ChildModel>?>(
      create: (context) async {
        final repo = context.read<ChildrenRepository>();
        if (teacherId != null) {
          return repo.getChildrenByTeacher(teacherId);
        }
        return repo.getAllChildren();
      },
      initialData: null,
      catchError: (context, error) => [],
    );
  }

  /// موفر قائمة الأطفال (Stream)
  static StreamProvider<List<ChildModel>> childrenStreamProvider(
      String? teacherId) {
    return StreamProvider<List<ChildModel>>(
      create: (context) {
        final repo = context.read<ChildrenRepository>();
        if (teacherId != null) {
          return repo.watchChildrenByTeacher(teacherId);
        }
        return Stream.value([]);
      },
      initialData: const [],
      catchError: (context, error) => [],
    );
  }

  /// موفر حضور اليوم (Stream)
  static StreamProvider<List<AttendanceModel>> todayAttendanceProvider() {
    return StreamProvider<List<AttendanceModel>>(
      create: (context) =>
          context.read<AttendanceRepository>().watchTodayAttendance(),
      initialData: const [],
      catchError: (context, error) => [],
    );
  }

  /// موفر الإشعارات (Stream)
  static StreamProvider<List<NotificationModel>> notificationsProvider(
      String userId) {
    return StreamProvider<List<NotificationModel>>(
      create: (context) =>
          context.read<NotificationRepository>().watchNotifications(userId),
      initialData: const [],
      catchError: (context, error) => [],
    );
  }

  /// موفر تقارير الطفل (Stream)
  static StreamProvider<List<ReportModel>> childReportsProvider(
      String childId) {
    return StreamProvider<List<ReportModel>>(
      create: (context) =>
          context.read<ReportRepository>().watchReports(childId),
      initialData: const [],
      catchError: (context, error) => [],
    );
  }

  /// موفر بيانات ولي الأمر  /// موفر ملف ولي الأمر (Future)
  static FutureProvider<GuardianModel?> guardianProfileProvider(String userId) {
    return FutureProvider<GuardianModel?>(
      create: (context) =>
          context.read<GuardianRepository>().getGuardianByUserId(userId),
      initialData: null,
      catchError: (context, error) => null,
    );
  }

  /// موفر بيانات المعلمة  /// موفر ملف المعلمة (Future)
  static FutureProvider<TeacherModel?> teacherProfileProvider(String userId) {
    return FutureProvider<TeacherModel?>(
      create: (context) =>
          context.read<TeacherRepository>().getTeacherByUserId(userId),
      initialData: null,
      catchError: (context, error) => null,
    );
  }

  /// موفر أطفال ولي الأمر (Stream)
  static StreamProvider<List<ChildModel>> guardianChildrenProvider(
      String guardianId) {
    return StreamProvider<List<ChildModel>>(
      create: (context) => context
          .read<ChildrenRepository>()
          .watchChildrenByGuardian(guardianId),
      initialData: const [],
      catchError: (context, error) => [],
    );
  }

  /// موفر إجمالي عدد الأطفال (Future)
  static FutureProvider<int> totalChildrenCountProvider() {
    return FutureProvider<int>(
      create: (context) async {
        final children =
            await context.read<ChildrenRepository>().getAllChildren();
        return children.length;
      },
      initialData: 0,
    );
  }

  /// موفر إجمالي عدد المعلمات (Future)
  static FutureProvider<int> totalTeachersCountProvider() {
    return FutureProvider<int>(
      create: (context) async {
        final teachers =
            await context.read<TeacherRepository>().getAllTeachers();
        return teachers.length;
      },
      initialData: 0,
    );
  }

  /// موفر إجمالي عدد أولياء الأمور (Future)
  static FutureProvider<int> totalGuardiansCountProvider() {
    return FutureProvider<int>(
      create: (context) async {
        final guardians =
            await context.read<GuardianRepository>().getAllGuardians();
        return guardians.length;
      },
      initialData: 0,
    );
  }
}
