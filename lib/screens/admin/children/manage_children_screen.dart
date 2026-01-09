import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class ManageChildrenScreen extends StatelessWidget {
  const ManageChildrenScreen({super.key});

  final List<Map<String, dynamic>> _dummyChildren = const [
    {
      'name': 'أحمد محمد',
      'age': 4,
      'gender': 'D',
      'guardian': 'ولي أمر أحمد',
      'teacher': 'سارة أحمد',
    },
    {
      'name': 'سارة علي',
      'age': 3,
      'gender': 'K',
      'guardian': 'ولي أمر سارة',
      'teacher': 'نورة العلي',
    },
    {
      'name': 'عمر خالد',
      'age': 5,
      'gender': 'D',
      'guardian': 'ولي أمر عمر',
      'teacher': 'منى سالم',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الأطفال'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/admin/children/add');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Center(
        child: SizedBox(
          width: screenWidth > 800 ? 800 : double.infinity,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _dummyChildren.length,
            itemBuilder: (context, index) {
              final child = _dummyChildren[index];
              final isBoy = child['gender'] == 'D';
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: isBoy
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.girl.withOpacity(0.1),
                    radius: 25,
                    child: Icon(
                      Icons.child_care,
                      color: isBoy ? AppColors.primary : AppColors.girl,
                    ),
                  ),
                  title: Text(
                    child['name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.face_3,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('ولي الأمر: ${child['guardian']}',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.person,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('المعلمة: ${child['teacher']}',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    icon: const Icon(Icons.more_vert,
                        color: AppColors.textSecondary),
                    onSelected: (value) {
                      if (value == 'edit') {
                        context.go('/admin/children/edit', extra: child);
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
