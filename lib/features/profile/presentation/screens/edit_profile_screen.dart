import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/entities/user_profile.dart';
import '../cubit/profile_info_cubit.dart';
import '../cubit/profile_info_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;

  String? _localAvatarPath;
  List<String> _interests = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current state values
    final state = context.read<ProfileInfoCubit>().state;
    if (state is ProfileInfoLoaded) {
      _fullNameController = TextEditingController(text: state.profile.fullName);
      _usernameController = TextEditingController(text: state.profile.username);
      _bioController = TextEditingController(text: state.profile.bio ?? '');
      _interests = List<String>.from(state.profile.interests);
    } else {
      _fullNameController = TextEditingController();
      _usernameController = TextEditingController();
      _bioController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _localAvatarPath = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل اختيار الصورة: $e')));
    }
  }

  void _addInterest() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('إضافة اهتمام', style: AppTextStyles.titleMd),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'مثال: موسيقى، تقنية...'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final interest = controller.text.trim();
              if (interest.isNotEmpty) {
                setState(() {
                  _interests.add(interest);
                });
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _removeInterest(String interest) {
    setState(() {
      _interests.remove(interest);
    });
  }

  void _saveProfile(UserProfile currentProfile) {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = currentProfile.copyWith(
        fullName: _fullNameController.text.trim(),
        username: _usernameController.text.trim().replaceAll('@', ''),
        bio: _bioController.text.trim(),
        interests: _interests,
      );

      context.read<ProfileInfoCubit>().updateProfileDetails(
        profile: updatedProfile,
        localAvatarPath: _localAvatarPath,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileInfoCubit, ProfileInfoState>(
      listener: (context, state) {
        if (state is ProfileInfoLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حفظ الملف الشخصي بنجاح')),
          );
          Navigator.pop(context);
        } else if (state is ProfileInfoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        UserProfile? currentProfile;
        bool isSaving = false;

        if (state is ProfileInfoLoaded) {
          currentProfile = state.profile;
        } else if (state is ProfileInfoUpdating) {
          currentProfile = state.currentProfile;
          isSaving = true;
        }

        if (currentProfile == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceContainerLowest,
            elevation: 0,
            leading: TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            title: Text(
              'Edit Profile',
              style: AppTextStyles.titleMd.copyWith(color: AppColors.onSurface),
            ),
            centerTitle: true,
            actions: [
              if (isSaving)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: () => _saveProfile(currentProfile!),
                  child: Text(
                    'Save',
                    style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.primaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Avatar section
                  _buildAvatarSection(currentProfile),
                  const SizedBox(height: 32),
                  // Form Fields
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F000000),
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Full Name'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _fullNameController,
                          enabled: !isSaving,
                          decoration: const InputDecoration(
                            hintText: 'Full Name',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'يرجى إدخال الاسم الكامل';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildLabel('Username'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _usernameController,
                          enabled: !isSaving,
                          decoration: const InputDecoration(
                            hintText: 'username',
                            prefixText: '@',
                            prefixStyle: TextStyle(
                              color: AppColors.outlineVariant,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'يرجى إدخال اسم المستخدم';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildLabel('Bio'),
                        const SizedBox(height: 8),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _bioController,
                          builder: (context, value, child) {
                            final count = value.text.length;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  controller: _bioController,
                                  enabled: !isSaving,
                                  maxLines: 4,
                                  maxLength: 160,
                                  buildCounter:
                                      (
                                        context, {
                                        required currentLength,
                                        required isFocused,
                                        maxLength,
                                      }) => null,
                                  decoration: const InputDecoration(
                                    hintText: 'Bio description...',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$count / 160',
                                  textAlign: TextAlign.right,
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.outlineVariant,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Interests tags
                  _buildInterestsSection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarSection(UserProfile profile) {
    ImageProvider? imageProvider;

    if (_localAvatarPath != null) {
      imageProvider = FileImage(File(_localAvatarPath!));
    } else if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
      imageProvider = NetworkImage(profile.avatarUrl!);
    }

    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surfaceContainerLowest,
                    width: 4,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: imageProvider != null
                      ? Image(image: imageProvider, fit: BoxFit.cover)
                      : Container(
                          color: AppColors.surfaceContainerHighest,
                          child: Center(
                            child: Text(
                              profile.fullName.isNotEmpty
                                  ? profile.fullName
                                        .substring(0, 1)
                                        .toUpperCase()
                                  : '?',
                              style: AppTextStyles.headlineLg.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.photo_camera,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _pickImage,
          child: Text(
            'Change Photo',
            style: AppTextStyles.labelSm.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.labelSm.copyWith(
        color: AppColors.onSurfaceVariant,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildInterestsSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Interests', style: AppTextStyles.titleMd),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: [
              ..._interests.map((interest) {
                return Chip(
                  label: Text(interest, style: AppTextStyles.labelSm),
                  backgroundColor: AppColors.primary.withOpacity(0.08),
                  labelStyle: const TextStyle(color: AppColors.primary),
                  deleteIcon: const Icon(
                    Icons.close,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  onDeleted: () => _removeInterest(interest),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  side: BorderSide.none,
                );
              }),
              ActionChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.add,
                      size: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                    SizedBox(width: 4),
                    Text('Add Interest', style: AppTextStyles.labelSm),
                  ],
                ),
                backgroundColor: Colors.transparent,
                onPressed: _addInterest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                  side: const BorderSide(
                    color: AppColors.outlineVariant,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
