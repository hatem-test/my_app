import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class ManageTeachersScreen extends StatelessWidget {
  const ManageTeachersScreen({super.key});

  final List<Map<String, dynamic>> _dummyTeachers = const [
    {
      'name': 'سارة أحمد',
      'email': 'sara@school.com',
      'phone': '0912345678',
      'role': 'معلمة صف',
    },
    {
      'name': 'نورة العلي',
      'email': 'noura@school.com',
      'phone': '0923456789',
      'role': 'مساعدة',
    },
    {
      'name': 'منى سالم',
      'email': 'mona@school.com',
      'phone': '0934567890',
      'role': 'معلمة لغة',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المعلمات'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/admin/teachers/add');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Center(
        child: SizedBox(
          width: screenWidth > 800 ? 800 : double.infinity,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _dummyTeachers.length,
            itemBuilder: (context, index) {
              final teacher = _dummyTeachers[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.backgroundSecondary,
                    radius: 25,
                    child: Icon(Icons.person, color: AppColors.primary),
                  ),
                  title: Text(
                    teacher['name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(teacher['role'],
                          style: const TextStyle(fontSize: 12)),
                      Text(teacher['email'],
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    icon: const Icon(Icons.more_vert,
                        color: AppColors.textSecondary),
                    onSelected: (value) {
                      if (value == 'edit') {
                        context.go('/admin/teachers/edit', extra: teacher);
                      }
                      // TODO: Implement delete
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit,
                                size: 18, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text('تعديل'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete,
                                size: 18, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('حذف'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
