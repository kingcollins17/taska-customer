import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seeker_app/core/core.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/widgets/custom_back_button.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/user_provider.dart';
import 'package:seeker_app/features/auth/presentation/verify_otp_screen.dart';

import 'widgets/auth_divider.dart';
import 'package:seeker_app/core/designs/widgets/custom_text_field.dart';
import 'package:seeker_app/core/designs/widgets/primary_button.dart';
import 'widgets/social_auth_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      context.showMessage(
        'Please fill all required fields',
        type: MessageType.error,
      );
      return;
    }
    if (password != confirm) {
      context.showMessage('Passwords do not match', type: MessageType.error);
      return;
    }

    final names = name.split(' ');
    final firstName = names.first;
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

    context.showLoading();

    ref
        .read(userProvider.notifier)
        .register(
          request: RegisterRequest(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
          ),
          onSuccess: () => _requestEmailOtp(email, password),
          onError: (message) {
            context.hideLoading();
            context.showMessage(message, type: MessageType.error);
          },
        );
  }

  void _requestEmailOtp(String email, String password) {
    ref
        .read(userProvider.notifier)
        .requestEmailOtp(
          request: RequestEmailOtpRequest(email: email),
          onSuccess: () {
            context.hideLoading();
            _showVerificationScreen(email, password);
          },
          onError: (msg) {
            context.hideLoading();
            context.showMessage(msg, type: MessageType.error);
          },
        );
  }

  void _showVerificationScreen(String email, String password) {
    VerifyOTPScreen.verify(
      context,
      verifier: (otp) => _verifyOtp(email, otp),
    ).then((result) {
      if (result != null && result.$1 == true) {
        context.showMessage(
          'Email verified successfully!',
          type: MessageType.success,
        );
        _loginAfterVerification(email, password);
      }
    });
  }

  Future<bool> _verifyOtp(String email, String otp) {
    final completer = Completer<bool>();
    ref
        .read(userProvider.notifier)
        .verifyEmail(
          request: VerifyEmailRequest(email: email, code: otp),
          onSuccess: () {
            completer.complete(true);
          },
          onError: (msg) {
            context.showMessage(msg, type: MessageType.error);
            completer.complete(false);
          },
        );
    return completer.future;
  }

  void _loginAfterVerification(String email, String password) {
    context.showLoading();
    ref
        .read(userProvider.notifier)
        .login(
          username: email,
          password: password,
          onSuccess: () {
            context.hideLoading();
            if (mounted) {
              context.go('/');
            }
          },
          onError: (msg) {
            context.hideLoading();
            context.showMessage(msg, type: MessageType.error);
            if (mounted) {
              context.go('/login');
            }
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),

              // Back Button
              const CustomBackButton(),

              SizedBox(height: 32.h),

              // Title
              Text(
                'Create your account',
                style: GoogleFonts.inter(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),

              SizedBox(height: 8.h),

              // Subtitle
              Text(
                'Join thousands discovering the best spots near you',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),

              SizedBox(height: 32.h),

              // Name Field
              CustomTextField(
                hintText: 'Full Name',
                leadingIcon: Icons.person_outline,
                controller: _nameController,
                keyboardType: TextInputType.name,
              ),

              SizedBox(height: 16.h),

              // Email Field
              CustomTextField(
                hintText: 'Email address',
                leadingIcon: Icons.mail_outline,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              SizedBox(height: 16.h),

              // Password Field
              CustomTextField(
                hintText: 'Password',
                leadingIcon: Icons.lock_outline,
                isPassword: true,
                controller: _passwordController,
              ),

              SizedBox(height: 16.h),

              // Confirm Password Field
              CustomTextField(
                hintText: 'Confirm Password',
                leadingIcon: Icons.lock_outline,
                isPassword: true,
                controller: _confirmPasswordController,
              ),

              SizedBox(height: 32.h),

              // Register Button
              PrimaryButton(text: 'Sign Up', onPressed: _handleRegister),

              SizedBox(height: 32.h),

              // Divider
              const AuthDivider(),

              SizedBox(height: 32.h),

              // Social Buttons
              Row(
                children: [
                  SocialAuthButton(
                    text: 'Google',
                    icon: Icons.g_mobiledata, // Placeholder
                    iconColor: Colors.redAccent,
                    onPressed: () {},
                  ),
                  SizedBox(width: 16.w),
                  SocialAuthButton(
                    text: 'Apple',
                    icon: Icons.apple,
                    onPressed: () {},
                  ),
                ],
              ),

              SizedBox(height: 48.h),

              // Login Link
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    children: [
                      TextSpan(
                        text: 'Log in',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.push('/login');
                            }
                          },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
