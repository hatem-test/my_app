import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/auth_service.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/role_selection_screen.dart';
import '../../screens/auth/create_account_screen.dart';
import '../../screens/mother/child_profile_screen.dart';
import '../../screens/mother/reports_screen.dart';
import '../../screens/home_screen.dart'; // Import HomeScreen wrapper
import '../../screens/mother/add_child_screen.dart';
import '../../screens/navigation_shell.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/splash_screen.dart';

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
        parentNavigatorKey:
            _rootNavigatorKey, // Define this key or let it default. For now assume push
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) =>
                    const HomeScreen(), // Use Role-Based Home
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
        return '/';
      }

      return null;
    },
  );
}
