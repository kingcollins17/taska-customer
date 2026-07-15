import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/designs/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final cardColor = isDark ? AppColors.darkerBackground : AppColors.surface;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My profile',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'View and manage your profile details below.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 32.h),
              
              // Profile Card with Banner
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    height: 120.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2A0845), Color(0xFF6441A5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30.h,
                    left: 20.w,
                    child: Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: bgColor, width: 3),
                        image: const DecorationImage(
                          image: NetworkImage('https://i.pravatar.cc/150?img=68'), // Placeholder
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30.h,
                    right: 20.w,
                    child: InkWell(
                      onTap: () => context.push('/profile-details'),
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cardColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(Icons.edit, color: AppColors.primary, size: 20.sp),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40.h),
              
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jelil Ajao',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Jelilajao@gmail.com',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 40.h),
              
              // Menu Items
              _buildMenuItem(context, Icons.lock_outline, 'Password management', Colors.green),
              _buildMenuItem(context, Icons.assignment_outlined, 'Task management', Colors.orange),
              _buildMenuItem(context, Icons.chat_bubble_outline, 'FAQs', Colors.blue),
              _buildMenuItem(context, Icons.email_outlined, 'Contact us', Colors.pink),
              _buildMenuItem(context, Icons.help_outline, 'About us', Colors.purple),
              
              SizedBox(height: 24.h),
              
              // Log Out
              _buildMenuItem(context, Icons.logout, 'Log out', Colors.red, isLogout: true),
              
              SizedBox(height: 80.h), // Spacing for bottom nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, Color iconColor, {bool isLogout = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isLogout ? Colors.red : (isDark ? Colors.white : AppColors.textPrimary);
    
    return InkWell(
      onTap: () {
        // Handle tap
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isLogout ? Colors.red : AppColors.textSecondary.withOpacity(0.5),
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }
}
