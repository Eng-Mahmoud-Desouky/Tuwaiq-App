import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({super.key, required this.navigationShell});

  void _onTap(BuildContext context, int index) {
    if (index == 2) {
      // The add button. We can either navigate to the branch or push a modal.
      // Assuming it's a branch for now.
      navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );
      return;
    }

    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(
              color: AppColors.outline,
              width: 0.5,
            ),
          ),
        ),
        padding: const EdgeInsets.only(bottom: 16, top: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavBarItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'الرئيسية',
              isActive: navigationShell.currentIndex == 0,
              onTap: () => _onTap(context, 0),
            ),
            _buildNavBarItem(
              icon: Icons.explore_outlined,
              activeIcon: Icons.explore,
              label: 'اكتشف',
              isActive: navigationShell.currentIndex == 1,
              onTap: () => _onTap(context, 1),
            ),
            GestureDetector(
              onTap: () => _onTap(context, 2),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: navigationShell.currentIndex == 2
                      ? AppColors.primary
                      : AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: navigationShell.currentIndex == 2
                        ? AppColors.primary
                        : AppColors.outline,
                    width: 0.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.event_note,
                  size: 24,
                  color: navigationShell.currentIndex == 2
                      ? Colors.black
                      : AppColors.secondary,
                ),
              ),
            ),
            _buildNavBarItem(
              icon: Icons.notifications_outlined,
              activeIcon: Icons.notifications,
              label: 'التنبيهات',
              isActive: navigationShell.currentIndex == 3,
              onTap: () => _onTap(context, 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: isActive ? AppColors.primary : AppColors.secondary,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: isActive ? AppColors.primary : AppColors.secondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
