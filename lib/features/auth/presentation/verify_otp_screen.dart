import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seeker_app/core/designs/widgets/custom_back_button.dart';
import 'package:seeker_app/core/designs/widgets/primary_button.dart';
import 'package:seeker_app/core/utils/flushbar_message.dart';
import 'package:seeker_app/core/utils/loading_overlay.dart';

class VerifyOTPScreen extends StatefulWidget {
  final String? title;
  final Future<bool> Function(String otp)? verifier;
  final Future<void> Function()? resender;

  const VerifyOTPScreen({super.key, this.title, this.verifier, this.resender});

  static Future<(bool, String)?> verify(
    BuildContext context, {
    String? title,
    Future<bool> Function(String otp)? verifier,
    Future<void> Function()? resender,
  }) {
    return Navigator.of(context).push<(bool, String)>(
      MaterialPageRoute(
        builder: (context) => VerifyOTPScreen(
          title: title,
          verifier: verifier,
          resender: resender,
        ),
      ),
    );
  }

  @override
  State<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  final int _otpLength = 6;
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  Timer? _resendTimer;
  int _remainingSeconds = 120;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(_otpLength, (index) => FocusNode());
    _controllers = List.generate(
      _otpLength,
      (index) => TextEditingController(),
    );
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() {
      _remainingSeconds = 120;
      _canResend = false;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  String _formatTimer(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onOtpChange(String value, int index) {
    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }

    if (_getOtp().length == _otpLength) {
      _verify();
    }
  }

  String _getOtp() {
    return _controllers.map((e) => e.text).join();
  }

  Future<void> _verify() async {
    final otp = _getOtp();
    if (otp.length < _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a complete code')),
      );
      return;
    }

    if (widget.verifier != null) {
      context.showLoading();
      try {
        final success = await widget.verifier!(otp);
        if (mounted) {
          context.hideLoading();
          if (success) {
            Navigator.of(context).pop((true, otp));
          } else {
            context.showMessage(
              'Invalid verification code',
              type: MessageType.error,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          context.hideLoading();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Verification failed: $e')));
        }
      }
    } else {
      // Just return the OTP if no verifier provided
      Navigator.of(context).pop((true, otp));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 16.h),
              const Align(
                alignment: Alignment.centerLeft,
                child: CustomBackButton(),
              ),
              SizedBox(height: 16.h),
              // App Logo placeholder based on UI mockup
              // Text(
              //   'Vitaria',
              //   style: GoogleFonts.inter(
              //     fontSize: 24.sp,
              //     fontWeight: FontWeight.w700,
              //     color: Theme.of(context).colorScheme.onSurface,
              //     fontStyle: FontStyle.italic,
              //   ),
              // ),
              // SizedBox(height: 48.h),
              Text(
                widget.title ?? 'Verify Account To\nContinue Now',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Enter the $_otpLength-digit code sent to you',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: 48.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  _otpLength,
                  (index) => SizedBox(
                    width: 48.w,
                    height: 56.h,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      onChanged: (value) => _onOtpChange(value, index),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.05),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onSurface,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 48.h),
              PrimaryButton(text: 'Verification', onPressed: _verify),
              SizedBox(height: 32.h),
              GestureDetector(
                onTap: _canResend
                    ? () async {
                        if (widget.resender != null) {
                          await widget.resender!();
                        }
                        _startResendTimer();
                      }
                    : null,
                child: RichText(
                  text: TextSpan(
                    text: "Didn't receive code? ",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    children: [
                      TextSpan(
                        text: _canResend
                            ? 'Resend Now'
                            : 'Resend in ${_formatTimer(_remainingSeconds)}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: _canResend
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.4),
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
    );
  }
}
