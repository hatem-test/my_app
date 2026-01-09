import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class ChildProfileScreen extends StatelessWidget {
  final String childId;
  const ChildProfileScreen({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    // Mock child data
    final child = {
      'name': 'أحمد محمد',
      'age': '4 سنوات',
      'gender': 'ذكر',
      'class': 'الصف الأول',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي للطفل'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/edit-child/$childId'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildChildInfoCard(context, child),
            const SizedBox(height: 32),
            _ActionGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildChildInfoCard(BuildContext context, Map<String, dynamic> child) {
    final isMale = child['gender'] == 'ذكر';
    final color = isMale ? AppColors.boy : AppColors.girl;
    final imagePath =
        isMale ? 'assets/images/boy.png' : 'assets/images/girl.png';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withOpacity(0.8),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ClipOval(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.person,
                    size: 35,
                    color: color,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child['name'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.cake_rounded, child['age']),
                const SizedBox(height: 4),
                _buildInfoRow(
                  isMale ? Icons.male_rounded : Icons.female_rounded,
                  child['gender'],
                ),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.class_rounded, child['class']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.white.withOpacity(0.9),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}

class _ActionGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _ActionButton(
          icon: Icons.assignment,
          label: 'التقارير',
          color: Colors.blue,
          onTap: () => context.push('/reports'),
        ),
        _ActionButton(
          icon: Icons.note,
          label: 'الملاحظات',
          color: Colors.orange,
          onTap: () {},
        ),
        _ActionButton(
          icon: Icons.restaurant,
          label: 'الوجبات',
          color: Colors.green,
          onTap: () {},
        ),
        _ActionButton(
          icon: Icons.medical_services,
          label: 'الحالة الصحية',
          color: Colors.red,
          onTap: () {},
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
