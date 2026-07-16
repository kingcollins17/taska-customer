import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/widgets/custom_text_field.dart';
import 'package:seeker_app/core/designs/widgets/primary_button.dart';

class PhoneNumberSheet extends StatefulWidget {
  const PhoneNumberSheet({super.key});

  static Future<String?> collect(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const PhoneNumberSheet(),
      ),
    );
  }

  @override
  State<PhoneNumberSheet> createState() => _PhoneNumberSheetState();
}

class _PhoneNumberSheetState extends State<PhoneNumberSheet> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop('+234${_phoneController.text.trim()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Add Phone Number',
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Please provide your phone number for verification.',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 24.h),
            CustomTextField(
              controller: _phoneController,
              hintText: '8012345678',
              prefixIconWidget: Padding(
                padding: EdgeInsets.only(left: 16.w, right: 8.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🇳🇬', style: TextStyle(fontSize: 20.sp)),
                    SizedBox(width: 8.w),
                    Text(
                      '+234',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      height: 24.h,
                      width: 1,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ],
                ),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (value.length < 10) {
                  return 'Please enter 10 digits';
                }
                return null;
              },
            ),
            SizedBox(height: 32.h),
            PrimaryButton(text: 'Continue', onPressed: _submit),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
