import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../core/constants/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.logout, color: AppColors.primary),
          onPressed: () {
            context.read<AuthCubit>().signOut();
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.signIn,
              (route) => false,
            );
          },
        ),
        title: const Text(
          'الرئيسية',
          style: AppTextStyles.titleSm,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: AppColors.primary),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'مرحباً بك في طويق',
          style: AppTextStyles.headlineMd,
        ),
      ),
    );
  }
}
