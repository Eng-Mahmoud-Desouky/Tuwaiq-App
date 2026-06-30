import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  double _passwordStrength = 0.0;
  Color _passwordStrengthColor = AppColors.error;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    final text = _passwordController.text;
    setState(() {
      if (text.isEmpty) {
        _passwordStrength = 0.0;
        _passwordStrengthColor = AppColors.error;
      } else if (text.length < 6) {
        _passwordStrength = 0.33;
        _passwordStrengthColor = AppColors.error;
      } else if (text.length < 10) {
        _passwordStrength = 0.66;
        _passwordStrengthColor = AppColors.secondaryFixedDim;
      } else {
        _passwordStrength = 1.0;
        _passwordStrengthColor = AppColors.primary;
      }
    });
  }

  void _onSignUpPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _usernameController.text.trim().replaceAll('@', ''),
        fullName: _fullNameController.text.trim(),
      );
    }
  }

  void _showSuccessOverlay(String email) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success Circle
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondaryFixedDim,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'تم إنشاء الحساب!',
                  style: AppTextStyles.headlineMd.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'مرحباً بك في عالم SCRATCH الحصري',
                  style: AppTextStyles.bodyLg.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Auto-navigate after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        // Dismiss dialog
        context.pop();
        // Go to Email Confirmation
        context.pushReplacement(
          AppRoutes.emailConfirmation,
          extra: email,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ],
        title: Center(
          child: Image.asset(
            'assets/images/logo.png',
            height: 32,
            fit: BoxFit.contain,
          ),
        ),
        leading: const SizedBox(width: 48), // Match balance
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthEmailNotConfirmed) {
            _showSuccessOverlay(state.email);
          } else if (state is AuthSuccess) {
            _showSuccessOverlay(state.user.email);
          } else if (state is AuthError) {
            context.showSnackBar(state.message, isError: true);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Section
                      Text(
                        'إنشاء حساب',
                        textAlign: TextAlign.right,
                        style: AppTextStyles.displayLgMobile.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'انضم إلى مجتمع SCRATCH',
                        textAlign: TextAlign.right,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Full Name
                      AuthTextField(
                        label: 'الاسم الكامل',
                        placeholder: 'الاسم الكامل',
                        controller: _fullNameController,
                        validator: Validators.validateFullName,
                      ),
                      const SizedBox(height: 16),
                      // Username
                      AuthTextField(
                        label: 'اسم المستخدم',
                        placeholder: 'اسم المستخدم',
                        controller: _usernameController,
                        prefixText: '@',
                        validator: Validators.validateUsername,
                      ),
                      const SizedBox(height: 16),
                      // Email
                      AuthTextField(
                        label: 'البريد الإلكتروني',
                        placeholder: 'البريد الإلكتروني',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 16),
                      // Password
                      AuthTextField(
                        label: 'كلمة المرور',
                        placeholder: 'كلمة المرور',
                        controller: _passwordController,
                        isPassword: true,
                        onChanged: _onPasswordChanged,
                        validator: Validators.validatePassword,
                      ),
                      // Strength Bar
                      if (_passwordStrength > 0.0) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: Container(
                            height: 4,
                            width: double.infinity,
                            color: AppColors.surfaceContainerLow,
                            alignment: Alignment.centerRight,
                            child: FractionallySizedBox(
                              widthFactor: _passwordStrength,
                              child: Container(color: _passwordStrengthColor),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Confirm Password
                      AuthTextField(
                        label: 'تأكيد كلمة المرور',
                        placeholder: 'تأكيد كلمة المرور',
                        controller: _confirmPasswordController,
                        isPassword: true,
                        validator: (val) => Validators.validateConfirmPassword(
                          val,
                          _passwordController.text,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Action Button (Sign Up)
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          return PrimaryButton(
                            text: 'إنشاء الحساب',
                            isLoading: state is AuthLoading,
                            onPressed: _onSignUpPressed,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      // Login Link Footer
                      Center(
                        child: TextButton(
                          onPressed: () {
                            context.pushReplacement(AppRoutes.signIn);
                          },
                          child: RichText(
                            text: TextSpan(
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.onSurface,
                              ),
                              children: const [
                                TextSpan(text: 'لديك حساب بالفعل؟ '),
                                TextSpan(
                                  text: 'تسجيل الدخول',
                                  style: TextStyle(
                                    color: AppColors.secondaryFixedDim,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
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
      ),
    );
  }
}
