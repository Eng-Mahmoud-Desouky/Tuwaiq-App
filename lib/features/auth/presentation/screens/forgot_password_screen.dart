import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isSuccess = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSubmitPressed() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _isSuccess = false;
      });

      try {
        await context.read<AuthCubit>().forgotPassword(
              email: _emailController.text.trim(),
            );
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isSuccess = true;
          });
          context.showSnackBar('تم إرسال رابط استعادة كلمة المرور بنجاح!');
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          context.showSnackBar('فشل إرسال الرابط: $e', isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: AppColors.primary),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    // Content Header Section
                    Text(
                      'استعادة كلمة المرور',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.displayLgMobile.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أدخل بريدك الإلكتروني وسنرسل لك رابط الاستعادة',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.bodyLg.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Email Field
                    AuthTextField(
                      label: 'البريد الإلكتروني',
                      placeholder: 'example@email.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 24),
                    // Decorative Peak Image Graphic
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuAHIUi2-bg_tKrUYLgG7nbgshGJeJ_ipCmmIhb4Pk-tGGjLYKN8lnl6wmEEeoM9ZJxhSbcd8nZ6AEs9cUQwF-126CO5gLa-2UecSzXNeGV5HGtEZxJ7HhmznvajqYAtBkp45DCbTolSUAbd5DW0Hs92oTHshs8I6j6zJ6L5iL5JFhLpoZg17KMFq_8-vTvKwXyNe_dtvzHff9myRpastEb2BCOEX4F9GwKGM6JhGL74ZQw2n1X1yK6fvG7efTycSe1sd7aqBWN59_c',
                                fit: BoxFit.cover,
                                color: Colors.black.withOpacity(0.85),
                                colorBlendMode: BlendMode.dstATop,
                                errorBuilder: (_, __, ___) => Container(
                                  color: AppColors.surfaceContainerLow,
                                  child: const Icon(
                                    Icons.terrain,
                                    color: AppColors.secondary,
                                    size: 48,
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.white.withOpacity(0.8),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Primary Action Button
                    PrimaryButton(
                      text: _isSuccess ? 'تم الإرسال بنجاح' : 'إرسال رابط الاستعادة',
                      isLoading: _isLoading,
                      onPressed: _isSuccess ? null : _onSubmitPressed,
                    ),
                    const SizedBox(height: 24),
                    // Help Link
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                          children: const [
                            TextSpan(text: 'هل تواجه مشكلة؟ '),
                            TextSpan(
                              text: 'تواصل مع الدعم',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
