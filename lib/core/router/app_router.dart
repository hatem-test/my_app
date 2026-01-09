import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
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
import '../../screens/mother/edit_child_profile_screen.dart';

// Teacher screens
import '../../screens/teacher/teacher_main_screen.dart';
import '../../screens/teacher/child_profile_screen.dart' as teacher;
import '../../screens/teacher/create_report_screen.dart';
import '../../screens/teacher/meals_screen.dart';
import '../../screens/teacher/health_screen.dart';
import '../../screens/teacher/notes_screen.dart';
import '../../screens/teacher/contact_screen.dart';
import '../../screens/teacher/profile/edit_profile_screen.dart';
import '../../screens/teacher/profile/change_password_screen.dart';
import '../../screens/teacher/profile/notification_settings_screen.dart';
import '../../screens/teacher/profile/help_support_screen.dart';
import '../../screens/admin/admin_navigation_shell.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/admin/children/manage_children_screen.dart';
import '../../screens/admin/users/manage_teachers_screen.dart';
import '../../screens/admin/users/manage_guardians_screen.dart';
import '../../screens/admin/users/add_edit_guardian_screen.dart';
import '../../screens/admin/users/add_edit_teacher_screen.dart';
import '../../screens/admin/children/add_edit_child_screen.dart';
import '../../screens/admin/monitoring/admin_reports_screen.dart';

class AppRouter {
  final AuthProvider authProvider;
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: authProvider,
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
        path: '/edit-child/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            EditChildProfileScreen(childId: state.pathParameters['id']!),
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
      GoRoute(
        path: '/teacher/profile/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/teacher/profile/change-password',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/teacher/profile/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/teacher/profile/help',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HelpSupportScreen(),
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

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdminNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin',
                builder: (context, state) => const AdminDashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'guardians',
                    builder: (context, state) => const ManageGuardiansScreen(),
                    routes: [
                      GoRoute(
                        path: 'add',
                        builder: (context, state) =>
                            const AddEditGuardianScreen(),
                      ),
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) {
                          final guardian = state.extra as Map<String, dynamic>;
                          return AddEditGuardianScreen(guardian: guardian);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'reports',
                    builder: (context, state) => const AdminReportsScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/teachers',
                builder: (context, state) => const ManageTeachersScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const AddEditTeacherScreen(),
                  ),
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) {
                      final teacher = state.extra as Map<String, dynamic>;
                      return AddEditTeacherScreen(teacher: teacher);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/children',
                builder: (context, state) => const ManageChildrenScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const AddEditChildScreen(),
                  ),
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) {
                      final child = state.extra as Map<String, dynamic>;
                      return AddEditChildScreen(child: child);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/profile',
                builder: (context, state) =>
                    const ProfileScreen(), // Reusing generic profile for now
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = authProvider.isAuthenticated;
      final userRole = authProvider.currentUser?.role;
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
        } else if (userRole?.name == 'admin') {
          return '/admin';
        }
        return '/';
      }

      return null;
    },
  );
}
