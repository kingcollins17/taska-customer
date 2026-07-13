import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seeker_app/core/core.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/widgets/custom_back_button.dart';
import 'package:seeker_app/core/providers/user_provider.dart';

import 'widgets/auth_divider.dart';
import 'package:seeker_app/core/designs/widgets/custom_text_field.dart';
import 'package:seeker_app/core/designs/widgets/primary_button.dart';
import 'widgets/social_auth_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      context.showMessage(
        'Please enter email and password',
        type: MessageType.error,
      );
      return;
    }

    context.showLoading();

    ref
        .read(userProvider.notifier)
        .login(
          username: email,
          password: password,
          onSuccess: () {
            context.hideLoading();
            // TODO: Navigate to Home once implemented
            context.showMessage('Login successful', type: MessageType.success);
            context.go('/');
          },
          onError: (message) {
            context.hideLoading();
            context.showMessage(message, type: MessageType.error);
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
                'Welcome back 👋',
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
                "Log in to see what's happening near you",
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),

              SizedBox(height: 32.h),

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

              SizedBox(height: 12.h),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Forgot Password',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // Login Button
              PrimaryButton(text: 'Log In', onPressed: _handleLogin),

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

              // Sign Up Link
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    children: [
                      TextSpan(
                        text: 'Sign up',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            context.push('/register');
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
