import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../cubit/auth_cubit.dart';

class EmailConfirmationScreen extends StatefulWidget {
  final String email;

  const EmailConfirmationScreen({
    super.key,
    required this.email,
  });

  @override
  State<EmailConfirmationScreen> createState() => _EmailConfirmationScreenState();
}

class _EmailConfirmationScreenState extends State<EmailConfirmationScreen> {
  bool _isResending = false;

  void _onOpenMailPressed() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
    );
    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        // Fallback if no email client registered
        context.showSnackBar('تعذر فتح تطبيق البريد تلقائياً. يرجى فتحه يدوياً.');
      }
    } catch (_) {
      context.showSnackBar('يرجى فتح تطبيق البريد الإلكتروني يدوياً.');
    }
  }

  void _onResendPressed() async {
    setState(() {
      _isResending = true;
    });

    try {
      await context.read<AuthCubit>().forgotPassword(email: widget.email);
      if (mounted) {
        context.showSnackBar('تم إعادة إرسال رابط التفعيل بنجاح!');
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('فشل إعادة الإرسال: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
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
      body: Stack(
        children: [
          // Visual Decoration Blur Shapes
          Positioned(
            top: 100,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryFixedDim.withOpacity(0.03),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tuwaiqGold.withOpacity(0.03),
              ),
            ),
          ),
          // Main Body Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Glowing Mail Icon
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer Glow
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.tuwaiqGold.withOpacity(0.04),
                              ),
                            ),
                            // Outline Circle
                            Container(
                              width: 128,
                              height: 128,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.tuwaiqGold.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.mail_outline,
                                color: AppColors.tuwaiqGold,
                                size: 80,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Title
                      Text(
                        'تحقق من بريدك',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.displayLgMobile.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Subtitle
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: AppTextStyles.bodyLg.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                          children: [
                            const TextSpan(text: 'أرسلنا رابط التفعيل إلى\n'),
                            TextSpan(
                              text: widget.email,
                              style: const TextStyle(
                                color: AppColors.tuwaiqGold,
                                fontWeight: FontWeight.bold,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Secondary Hint Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.outlineVariant.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          'تحقق من صندوق الوارد أو مجلد الرسائل غير المرغوب فيها لتفعيل حسابك ومتابعة التسجيل.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Open Mail Button
                      PrimaryButton(
                        text: 'فتح تطبيق البريد',
                        onPressed: _onOpenMailPressed,
                      ),
                      const SizedBox(height: 24),
                      // Resend link and email change links
                      Column(
                        children: [
                          TextButton(
                            onPressed: _isResending ? null : _onResendPressed,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isResending) ...[
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.tuwaiqGold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  'إعادة الإرسال',
                                  style: AppTextStyles.bodyLg.copyWith(
                                    color: AppColors.tuwaiqGold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'لم تستلم الرسالة؟',
                                  style: AppTextStyles.bodyLg.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'تغيير البريد الإلكتروني',
                              style: AppTextStyles.labelCaps.copyWith(
                                color: AppColors.onSurfaceVariant.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
