import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class ManageGuardiansScreen extends StatelessWidget {
  const ManageGuardiansScreen({super.key});

  final List<Map<String, dynamic>> _dummyGuardians = const [
    {
      'name': 'ولي أمر أحمد',
      'email': 'parent_ahmed@mail.com',
      'phone': '0912345678',
      'children': 'أحمد',
    },
    {
      'name': 'أم سارة',
      'email': 'um_sara@mail.com',
      'phone': '0923456789',
      'children': 'سارة',
    },
    {
      'name': 'أم عمر',
      'email': 'um_omar@mail.com',
      'phone': '0934567890',
      'children': 'عمر',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة أولياء الأمور'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/admin/guardians/add');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Center(
        child: SizedBox(
          width: screenWidth > 800 ? 800 : double.infinity,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _dummyGuardians.length,
            itemBuilder: (context, index) {
              final guardian = _dummyGuardians[index];
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
                    child: Icon(Icons.face_3, color: AppColors.accent),
                  ),
                  title: Text(
                    guardian['name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('الأطفال: ${guardian['children']}',
                          style: const TextStyle(fontSize: 12)),
                      Text(guardian['email'],
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    icon: const Icon(Icons.more_vert,
                        color: AppColors.textSecondary),
                    onSelected: (value) {
                      if (value == 'edit') {
                        context.go('/admin/guardians/edit', extra: guardian);
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
