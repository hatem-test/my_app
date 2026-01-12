import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'repositories/auth_repository.dart';
import 'services/auth_service.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/app_provider.dart';
import 'core/router/app_router.dart';
import 'services/supabase_config.dart';
import 'repositories/children_repository.dart';
import 'repositories/attendance_repository.dart';
import 'repositories/health_record_repository.dart';
import 'repositories/meal_repository.dart';
import 'repositories/note_repository.dart';
import 'repositories/notification_repository.dart';
import 'repositories/report_repository.dart';
import 'repositories/teacher_repository.dart';
import 'repositories/guardian_repository.dart';
import 'core/providers/teacher_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => AuthRepository()),
        Provider(create: (_) => ChildrenRepository()),
        Provider(create: (_) => AttendanceRepository()),
        Provider(create: (_) => HealthRecordRepository()),
        Provider(create: (_) => MealRepository()),
        Provider(create: (_) => NoteRepository()),
        Provider(create: (_) => NotificationRepository()),
        Provider(create: (_) => ReportRepository()),
        Provider(create: (_) => TeacherRepository()),
        Provider(create: (_) => GuardianRepository()),
        ProxyProvider3<AuthRepository, GuardianRepository, TeacherRepository,
            AuthService>(
          update: (_, authRepo, guardianRepo, teacherRepo, __) =>
              AuthService(authRepo, guardianRepo, teacherRepo),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(context.read<AuthService>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              TeacherProvider(context.read<TeacherRepository>()),
        ),
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: Builder(
        builder: (context) {
          return Provider<AppRouter>(
            create: (_) => AppRouter(context.read<AuthProvider>()),
            child: Builder(
              builder: (context) {
                final router = context.read<AppRouter>().router;
                final appProvider = context.watch<AppProvider>();
                return MaterialApp.router(
                  title: 'Nursery App',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  themeMode: appProvider.themeMode,
                  routerConfig: router,
                  locale: appProvider.locale,
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('ar'),
                    Locale('en'),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
