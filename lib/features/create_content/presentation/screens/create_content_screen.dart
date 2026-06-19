import 'package:flutter/material.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/theme/app_colors.dart';

class CreateContentScreen extends StatelessWidget {
  const CreateContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create', style: AppTextStyles.titleSm),
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
