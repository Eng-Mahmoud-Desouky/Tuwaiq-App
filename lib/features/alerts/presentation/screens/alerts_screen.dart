import 'package:flutter/material.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/theme/app_colors.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Alerts', style: AppTextStyles.titleSm),
        centerTitle: true,
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
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
