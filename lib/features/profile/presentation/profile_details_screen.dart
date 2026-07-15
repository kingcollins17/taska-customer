import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/designs/app_colors.dart';
import '../../../../core/designs/widgets/primary_button.dart';

class ProfileDetailsScreen extends StatelessWidget {
  const ProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final cardColor = isDark ? AppColors.darkerBackground : AppColors.surface;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cardColor,
            ),
            child: Icon(Icons.arrow_back_ios_new, color: textColor, size: 16.sp),
          ),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Details',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              'View and edit personal details.',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              
              // Profile Picture Center
              Center(
                child: Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: const DecorationImage(
                      image: NetworkImage('https://i.pravatar.cc/150?img=68'), // Placeholder
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              
              // Form Fields
              _buildLabel('Full name', textColor),
              _buildTextField('Jelil Ajao', Icons.person_outline, cardColor, textColor),
              SizedBox(height: 20.h),
              
              _buildLabel('Email address', textColor),
              _buildTextField('Jelilajao@gmail.com', Icons.email_outlined, cardColor, textColor),
              SizedBox(height: 20.h),
              
              _buildLabel('Phone number', textColor),
              _buildTextField('08103461256', Icons.phone_android_outlined, cardColor, textColor),
              SizedBox(height: 24.h),
              
              _buildLabel('Tasks completed', textColor),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _buildTag('Plumbing', cardColor, textColor),
                  _buildTag('Cleaning', cardColor, textColor),
                  _buildTag('Repairs', cardColor, textColor),
                ],
              ),
              
              SizedBox(height: 60.h),
              
              PrimaryButton(
                text: 'Edit profile',
                backgroundColor: Colors.green, // As requested in design
                foregroundColor: Colors.white,
                onPressed: () {
                  // Handle save
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color textColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, IconData suffixIcon, Color cardColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
      ),
      child: TextField(
        style: TextStyle(color: textColor, fontSize: 16.sp),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: textColor.withOpacity(0.7)),
          suffixIcon: Icon(suffixIcon, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color cardColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          color: textColor,
        ),
      ),
    );
  }
}
