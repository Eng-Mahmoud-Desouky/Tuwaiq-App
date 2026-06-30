import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_routes.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../theme/app_colors.dart';

class AppBarAvatar extends StatelessWidget {
  const AppBarAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          final user = state.user;
          final avatarUrl = user.avatarUrl;

          return GestureDetector(
            onTap: () {
              context.go(AppRoutes.profile);
            },
            child: Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.outline,
                    width: 1.0,
                  ),
                ),
                child: ClipOval(
                  child: avatarUrl != null && avatarUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: avatarUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
                          errorWidget: (context, url, error) => _buildPlaceholder(user.username),
                        )
                      : _buildPlaceholder(user.username),
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPlaceholder(String username) {
    final firstLetter = username.isNotEmpty ? username[0].toUpperCase() : 'S';
    return Container(
      color: AppColors.primary.withOpacity(0.2),
      alignment: Alignment.center,
      child: Text(
        firstLetter,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
