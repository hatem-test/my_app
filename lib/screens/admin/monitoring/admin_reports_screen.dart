import 'package:flutter/material.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل التقارير'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('سجل التقارير - قريباً'),
      ),
    );
  }
}
