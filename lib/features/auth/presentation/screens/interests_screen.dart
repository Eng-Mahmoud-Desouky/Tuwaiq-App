import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_interests.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final Set<String> _selectedInterestIds = {};

  void _onInterestTapped(String interestId) {
    setState(() {
      if (_selectedInterestIds.contains(interestId)) {
        _selectedInterestIds.remove(interestId);
      } else {
        _selectedInterestIds.add(interestId);
      }
    });
  }

  void _onExplorePressed() {
    if (_selectedInterestIds.length >= 3) {
      context.read<AuthCubit>().saveUserInterests(
        interests: _selectedInterestIds.toList(),
      );
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'campaign':
        return Icons.campaign;
      case 'music_note':
        return Icons.music_note;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'palette':
        return Icons.palette;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'restaurant':
        return Icons.restaurant;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'menu_book':
        return Icons.menu_book;
      case 'terrain':
        return Icons.terrain;
      case 'business_center':
        return Icons.business_center;
      case 'groups':
        return Icons.groups;
      case 'theater_comedy':
        return Icons.theater_comedy;
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int selectedCount = _selectedInterestIds.length;
    final bool canProceed = selectedCount >= 3;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.showSnackBar('تم حفظ اهتماماتك بنجاح! مرحباً بك في طويق.');
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            );
          } else if (state is AuthError) {
            context.showSnackBar(state.message, isError: true);
          }
        },
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step Indicators
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 6,
                      width: 32,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 6,
                      width: 32,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 6,
                      width: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
              // Header Content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'ما الذي يثير اهتمامك؟',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.displayLgMobile.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'اختر اهتماماتك لنخصص لك أفضل الفعاليات',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.bodyLg.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Interests Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: AppInterests.list.length,
                  itemBuilder: (context, index) {
                    final item = AppInterests.list[index];
                    final isSelected = _selectedInterestIds.contains(item.id);

                    return GestureDetector(
                      onTap: () => _onInterestTapped(item.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getIconData(item.icon),
                              size: 36,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.name,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.titleSm.copyWith(
                                color: AppColors.primary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Hint Text
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Text(
                  canProceed
                      ? 'رائع! يمكنك الآن الاستمرار'
                      : 'اختر ${3 - selectedCount} إضافية على الأقل',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySm.copyWith(
                    color: canProceed
                        ? AppColors.secondary
                        : AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Explore Action Footer
              Padding(
                padding: const EdgeInsets.all(20),
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    return PrimaryButton(
                      text: 'ابدأ الاستكشاف',
                      icon: Icons
                          .arrow_back, // arrow_forward rotated 180 for RTL is left-facing arrow
                      isLoading: state is AuthLoading,
                      onPressed: canProceed ? _onExplorePressed : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
