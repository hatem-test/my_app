import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart';
import '../models/models.dart';
import 'mother/mother_home_screen.dart';
import 'teacher/teacher_home_screen.dart';
import 'admin/admin_dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    switch (user.role) {
      case UserRole.mother:
        return const MotherHomeScreen();
      case UserRole.teacher:
        return const TeacherHomeScreen();
      case UserRole.admin:
        return const AdminDashboardScreen();
    }
  }
}
