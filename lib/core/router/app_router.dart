import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/auth_service.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/mother/child_profile_screen.dart';
import '../../screens/mother/reports_screen.dart';
import '../../screens/home_screen.dart'; // Import HomeScreen wrapper
import '../../screens/mother/add_child_screen.dart';
import '../../screens/navigation_shell.dart';

class AppRouter {
  final AuthService authService;
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  AppRouter(this.authService);

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: authService,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
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
                builder: (context, state) =>
                    const Scaffold(body: Center(child: Text('الملف الشخصي'))),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = authService.isAuthenticated;
      final isLoggingIn = state.uri.toString() == '/login';
      final isSelectingRole = state.uri.toString() == '/role-selection';

      if (!isLoggedIn && !isLoggingIn && !isSelectingRole) {
        return '/role-selection';
      }
      if (isLoggedIn && (isLoggingIn || isSelectingRole)) return '/';

      return null;
    },
  );
}
