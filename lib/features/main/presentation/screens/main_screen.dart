import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({super.key, required this.navigationShell});

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomAppBar(
        color: AppColors.background,
        elevation: 0,
        padding: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(
              top: BorderSide(
                color: AppColors.outline,
                width: 0.5,
              ),
            ),
          ),
          padding: const EdgeInsets.only(bottom: 8, top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildNavBarItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'الرئيسية',
                  isActive: navigationShell.currentIndex == 0,
                  onTap: () => _onTap(context, 0),
                ),
              ),
              Expanded(
                child: _buildNavBarItem(
                  icon: Icons.search,
                  activeIcon: Icons.search,
                  label: 'بحث',
                  isActive: navigationShell.currentIndex == 1,
                  onTap: () => _onTap(context, 1),
                ),
              ),
              Expanded(
                child: _buildNavBarItem(
                  icon: Icons.notifications_outlined,
                  activeIcon: Icons.notifications,
                  label: 'التنبيهات',
                  isActive: navigationShell.currentIndex == 2,
                  onTap: () => _onTap(context, 2),
                ),
              ),
              Expanded(
                child: _buildNavBarItem(
                  icon: Icons.mail_outlined,
                  activeIcon: Icons.mail,
                  label: 'رسايل',
                  isActive: navigationShell.currentIndex == 3,
                  onTap: () => _onTap(context, 3),
                ),
              ),
            ],
          ),
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
