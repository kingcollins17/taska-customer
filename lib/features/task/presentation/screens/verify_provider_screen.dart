import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/widgets/custom_back_button.dart';
import 'package:seeker_app/core/designs/widgets/primary_button.dart';
import 'package:seeker_app/core/utils/flushbar_message.dart';
import 'package:seeker_app/features/task/presentation/widgets/provider_identity_result_sheet.dart';

class VerifyProviderScreen extends ConsumerStatefulWidget {
  final String taskId;

  const VerifyProviderScreen({super.key, required this.taskId});

  @override
  ConsumerState<VerifyProviderScreen> createState() =>
      _VerifyProviderScreenState();

}

class _VerifyProviderScreenState extends ConsumerState<VerifyProviderScreen> {
  static const int _pinLength = 4;
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(_pinLength, (index) => FocusNode());
    _controllers = List.generate(
      _pinLength,
      (index) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onPinChange(String value, int index) {
    if (value.isNotEmpty) {
      if (index < _pinLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }

    if (_getPin().length == _pinLength) {
      _verify();
    }
  }

  String _getPin() {
    return _controllers.map((e) => e.text).join();
  }

  void _verify() {
    final pin = _getPin();
    if (pin.length < _pinLength) {
      context.showMessage(
        'Please enter a complete 4-digit PIN',
        type: MessageType.error,
      );
      return;
    }

    FocusScope.of(context).unfocus();
    ProviderIdentityResultSheet.show(
      context,
      taskId: widget.taskId,
      pin: pin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
              SizedBox(height: 20.h),

              // Header Title & Subtitle
              Text(
                'Verify Provider\nIdentity',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Enter the 4-digit PIN provided by your assigned provider to confirm their identity for your safety.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
              SizedBox(height: 36.h),

              // 4-Digit PIN Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  _pinLength,
                  (index) => SizedBox(
                    width: 60.w,
                    height: 68.h,
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
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                      onChanged: (value) => _onPinChange(value, index),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        filled: true,
                        fillColor: colorScheme.onSurface
                            .withValues(alpha: 0.05),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(
                            color: colorScheme.onSurface
                                .withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 36.h),

              // Verification Submit Button
              PrimaryButton(text: 'Verify Identity', onPressed: _verify),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
