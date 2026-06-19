import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({
    super.key,
    required this.navigationShell,
  });

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
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 24,
              offset: Offset(0, -8),
            )
          ],
        ),
        padding: const EdgeInsets.only(bottom: 16, top: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavBarItem(
              icon: Icons.home_outlined,
              label: 'Home',
              isActive: navigationShell.currentIndex == 0,
              onTap: () => _onTap(context, 0),
            ),
            _buildNavBarItem(
              icon: Icons.explore_outlined,
              label: 'Explore',
              isActive: navigationShell.currentIndex == 1,
              onTap: () => _onTap(context, 1),
            ),
            GestureDetector(
              onTap: () => _onTap(context, 2),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(Icons.add, size: 28, color: Colors.white),
              ),
            ),
            _buildNavBarItem(
              icon: Icons.notifications_outlined,
              label: 'Alerts',
              isActive: navigationShell.currentIndex == 3,
              onTap: () => _onTap(context, 3),
            ),
            _buildNavBarItem(
              icon: Icons.person,
              label: 'Profile',
              isActive: navigationShell.currentIndex == 4,
              onTap: () => _onTap(context, 4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem({
    required IconData icon,
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
            icon,
            color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
