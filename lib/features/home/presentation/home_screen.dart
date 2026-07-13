import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seeker_app/core/designs/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 16.h, bottom: 100.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              SizedBox(height: 32.h),
              _buildHeader(),
              SizedBox(height: 24.h),
              _buildPostInput(),
              SizedBox(height: 32.h),
              _buildSectionTitle('Activity Overview', 'View all'),
              SizedBox(height: 16.h),
              _buildPostCard(
                name: 'Sarah Johnson',
                title: '10 Essential Stock Market Tips',
                description: 'Learn the core rules every beginner needs to invest with before confidence.',
                likes: 250,
                comments: 105,
                hours: 20,
              ),
              SizedBox(height: 16.h),
              _buildPostCard(
                name: 'Sarah Johnson',
                title: 'Smarter Diversification with REITs',
                description: 'REITs help you spread risk while unlocking steady real estate returns.',
                likes: 250,
                comments: 105,
                hours: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20.r,
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          child: Icon(Icons.person, color: Colors.white, size: 24.sp), // Placeholder for image
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sarah Johnson',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Good Morning',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Icon(Icons.notifications_none_outlined, color: Colors.white, size: 20.sp),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Text(
      'Let\'s Talk About Your\nBusiness Idea Today',
      style: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 28.sp,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildPostInput() {
    return Container(
      padding: EdgeInsets.only(left: 20.w, right: 6.w, top: 6.h, bottom: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(40.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Type name here....',
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 14.sp,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Text(
              'Post now',
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          action,
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPostCard({
    required String name,
    required String title,
    required String description,
    required int likes,
    required int comments,
    required int hours,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                child: Icon(Icons.person, color: Colors.white, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Good Morning',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                child: Icon(Icons.more_horiz, color: Colors.white, size: 20.sp),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            description,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              _buildInteractionButton(Icons.thumb_up_alt_outlined, likes.toString()),
              SizedBox(width: 12.w),
              _buildInteractionButton(Icons.chat_bubble_outline, comments.toString()),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.white.withValues(alpha: 0.5), size: 16.sp),
                  SizedBox(width: 6.w),
                  Text(
                    '$hours Hrs',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 16.sp),
          SizedBox(width: 6.w),
          Text(
            text,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}
