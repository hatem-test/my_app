import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/auth_service.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/role_selection_screen.dart';
import '../../screens/auth/create_account_screen.dart';
import '../../screens/mother/child_profile_screen.dart';
import '../../screens/mother/reports_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/mother/add_child_screen.dart';
import '../../screens/navigation_shell.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/splash_screen.dart';

// Teacher screens
import '../../screens/teacher/teacher_main_screen.dart';
import '../../screens/teacher/child_profile_screen.dart' as teacher;
import '../../screens/teacher/create_report_screen.dart';
import '../../screens/teacher/meals_screen.dart';
import '../../screens/teacher/health_screen.dart';
import '../../screens/teacher/notes_screen.dart';
import '../../screens/teacher/contact_screen.dart';

class AppRouter {
  final AuthService authService;
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  AppRouter(this.authService);

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: authService,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/create-account',
        builder: (context, state) => const CreateAccountScreen(),
      ),
      GoRoute(
        path: '/add-child',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddChildScreen(),
      ),
      GoRoute(
        path: '/child/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            ChildProfileScreen(childId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/reports',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ReportsScreen(),
      ),

      // Teacher Routes
      GoRoute(
        path: '/teacher',
        builder: (context, state) => const TeacherMainScreen(),
      ),
      GoRoute(
        path: '/teacher/child/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            teacher.ChildProfileScreen(childId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/teacher/report',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateReportScreen(),
      ),
      GoRoute(
        path: '/teacher/report/:childId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            CreateReportScreen(childId: state.pathParameters['childId']),
      ),
      GoRoute(
        path: '/teacher/meals/:childId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            MealsScreen(childId: state.pathParameters['childId']),
      ),
      GoRoute(
        path: '/teacher/health/:childId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            HealthScreen(childId: state.pathParameters['childId']),
      ),
      GoRoute(
        path: '/teacher/notes/:childId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            NotesScreen(childId: state.pathParameters['childId']),
      ),
      GoRoute(
        path: '/teacher/contact/:childId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            ContactScreen(childId: state.pathParameters['childId']),
      ),

      // Mother navigation shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                builder: (context, state) =>
                    const Scaffold(body: Center(child: Text('الإشعارات'))),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                builder: (context, state) =>
                    const Scaffold(body: Center(child: Text('الدردشة'))),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = authService.isAuthenticated;
      final userRole = authService.currentUser?.role;
      final isLoggingIn = state.uri.path == '/login';
      final isSelectingRole = state.uri.path == '/role-selection';
      final isCreatingAccount = state.uri.path == '/create-account';
      final isSplash = state.uri.path == '/splash';

      if (isSplash) {
        return null;
      }

      if (!isLoggedIn &&
          !isLoggingIn &&
          !isSelectingRole &&
          !isCreatingAccount) {
        return '/role-selection';
      }

      if (isLoggedIn && (isLoggingIn || isSelectingRole || isCreatingAccount)) {
        // Redirect based on user role
        if (userRole?.name == 'teacher') {
          return '/teacher';
        }
        return '/';
      }

      return null;
    },
  );
}
