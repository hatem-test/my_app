import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class AdminNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AdminNavigationShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        height: 70 + MediaQuery.of(context).padding.bottom / 2,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'الرئيسية',
                isSelected: navigationShell.currentIndex == 0,
                onTap: () => _onTap(context, 0),
                width: width,
              ),
              _NavBarItem(
                icon: Icons.people_outline,
                activeIcon: Icons.people,
                label: 'المعلمات',
                isSelected: navigationShell.currentIndex == 1,
                onTap: () => _onTap(context, 1),
                width: width,
              ),
              _NavBarItem(
                icon: Icons.child_care_outlined,
                activeIcon: Icons.child_care,
                label: 'الأطفال',
                isSelected: navigationShell.currentIndex == 2,
                onTap: () => _onTap(context, 2),
                width: width,
              ),
              _NavBarItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'الملف الشخصي',
                isSelected: navigationShell.currentIndex == 3,
                onTap: () => _onTap(context, 3),
                width: width,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double width;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: width * 0.02),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSlide(
              offset: isSelected ? const Offset(0, -0.2) : Offset.zero,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: width * 0.07,
              ),
            ),
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isSelected
                  ? Text(
                      label,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: width * 0.03,
                      ),
                    )
                  : const SizedBox(),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
              )
          ],
        ),
      ),
    );
  }
}
