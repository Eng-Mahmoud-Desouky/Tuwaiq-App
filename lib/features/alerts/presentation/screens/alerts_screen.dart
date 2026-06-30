import 'package:flutter/material.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/app_bar_avatar.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          r'$CRATCH',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        leading: const AppBarAvatar(),
        shape: const Border(
          bottom: BorderSide(
            color: AppColors.outline,
            width: 0.5,
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Coming Soon',
          style: AppTextStyles.headlineMd.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}
