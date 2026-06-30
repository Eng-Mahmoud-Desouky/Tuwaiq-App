import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../cubits/create_post/create_post_cubit.dart';
import '../cubits/create_post/create_post_state.dart';
import '../cubits/post_feed/post_feed_cubit.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  int _charCount = 0;
  static const int _maxChars = 2000;

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    _contentController.removeListener(_onContentChanged);
    _contentController.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    setState(() {
      _charCount = _contentController.text.length;
    });
  }

  void _handleSubmit(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تسجيل الدخول أولاً')),
      );
      return;
    }

    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن نشر منشور فارغ')),
      );
      return;
    }

    if (content.length > _maxChars) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لقد تجاوزت الحد الأقصى للحروف')),
      );
      return;
    }

    final userProfile = UserProfile(
      id: authState.user.id,
      fullName: authState.user.fullName,
      username: authState.user.username,
      bio: authState.user.bio,
      avatarUrl: authState.user.avatarUrl,
      interests: authState.user.interests,
    );

    context.read<CreatePostCubit>().submitPost(
          content: content,
          creatorId: authState.user.id,
          creator: userProfile,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'إنشاء منشور جديد',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
      ),
      body: BlocListener<CreatePostCubit, CreatePostState>(
        listener: (context, state) {
          if (state is CreatePostSuccess) {
            // Prepend new post to feed
            context.read<PostFeedCubit>().onPostAdded(state.post);
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم نشر منشورك بنجاح')),
            );
            
            // Pop the screen safely using mounted check guard
            if (mounted) {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go(AppRoutes.home);
              }
            }
          } else if (state is CreatePostError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: BlocBuilder<CreatePostCubit, CreatePostState>(
          builder: (context, state) {
            final isLoading = state is CreatePostLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Form Container Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Text Field Input
                        TextField(
                          controller: _contentController,
                          maxLines: 8,
                          maxLength: _maxChars,
                          style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
                          buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                          decoration: InputDecoration(
                            hintText: 'ماذا يدور في ذهنك اليوم؟...',
                            hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.secondary.withOpacity(0.7)),
                            border: InputBorder.none,
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Custom Character Counter
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$_charCount / $_maxChars',
                              style: AppTextStyles.labelSm.copyWith(
                                color: _charCount > _maxChars ? AppColors.error : AppColors.secondary,
                              ),
                            ),
                            if (state.imagePath == null)
                              TextButton.icon(
                                onPressed: isLoading
                                    ? null
                                    : () => context.read<CreatePostCubit>().selectImage(),
                                icon: const Icon(Icons.image_outlined, color: AppColors.primary),
                                label: Text(
                                  'إضافة صورة',
                                  style: AppTextStyles.labelLg.copyWith(color: AppColors.primary),
                                ),
                              ),
                          ],
                        ),

                        // Image Preview (if selected)
                        if (state.imagePath != null) ...[
                          const SizedBox(height: 16),
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(state.imagePath!),
                                  width: double.infinity,
                                  height: 220,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  backgroundColor: Colors.black.withOpacity(0.6),
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white),
                                    onPressed: isLoading
                                        ? null
                                        : () => context.read<CreatePostCubit>().removeImage(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Submit Button
                  PrimaryButton(
                    text: 'نشر الآن',
                    isLoading: isLoading,
                    onPressed: isLoading ? null : () => _handleSubmit(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
