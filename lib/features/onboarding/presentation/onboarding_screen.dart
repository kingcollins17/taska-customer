import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:seeker_app/core/designs/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      imagePath: 'assets/images/onboarding_post_task.png',
      title: 'Post Tasks\nEffortlessly',
      subtitle:
          'Describe what you need done, set your budget, and let qualified professionals come to you.',
      accentColor: AppColors.accentPurple,
    ),
    OnboardingData(
      imagePath: 'assets/images/onboarding_professionals.png',
      title: 'Vetted Pros\nNear You',
      subtitle:
          'Access highly vetted professionals within your locality. Trusted, verified, and ready to help.',
      accentColor: AppColors.accentOrange,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _onContinue() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.go('/login');
    }
  }

  void _onSkip() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // Page View
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _OnboardingPage(
                data: _pages[index],
                isActive: _currentPage == index,
              );
            },
          ),

          // Bottom Controls Overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomControls(
              currentPage: _currentPage,
              totalPages: _pages.length,
              accentColor: _pages[_currentPage].accentColor,
              onContinue: _onContinue,
              onSkip: _onSkip,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data Model ──────────────────────────────────────────────────────────────

class OnboardingData {
  final String imagePath;
  final String title;
  final String subtitle;
  final Color accentColor;

  const OnboardingData({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });
}

// ─── Onboarding Page ─────────────────────────────────────────────────────────

class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final bool isActive;

  const _OnboardingPage({required this.data, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Hero Image
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.65,
          child: Hero(
            tag: data.imagePath,
            child: Image.asset(data.imagePath, fit: BoxFit.cover),
          ),
        ),

        // Gradient overlay — smooth fade from image into dark
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.70,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  AppColors.darkBackground.withValues(alpha: 0.3),
                  AppColors.darkBackground.withValues(alpha: 0.85),
                  AppColors.darkBackground,
                ],
                stops: const [0.0, 0.35, 0.55, 0.75, 1.0],
              ),
            ),
          ),
        ),

        // Subtle accent glow behind the image
        Positioned(
          top: MediaQuery.of(context).size.height * 0.25,
          left: -50,
          right: -50,
          child: Container(
            height: 200.h,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  data.accentColor.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
                radius: 1.0,
              ),
            ),
          ),
        ),

        // Top vignette
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 120.h,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.darkBackground.withValues(alpha: 0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Content
        Positioned(
          left: 24.w,
          right: 24.w,
          bottom: 180.h + MediaQuery.of(context).padding.bottom,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                    data.title,
                    style: GoogleFonts.inter(
                      fontSize: 34.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                  )
                  .animate(target: isActive ? 1 : 0)
                  .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                  .slideY(
                    begin: 0.15,
                    end: 0,
                    duration: 600.ms,
                    curve: Curves.easeOut,
                  ),
              SizedBox(height: 12.h),
              // Subtitle
              Text(
                    data.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.65),
                      height: 1.5,
                    ),
                  )
                  .animate(target: isActive ? 1 : 0)
                  .fadeIn(
                    duration: 600.ms,
                    delay: 150.ms,
                    curve: Curves.easeOut,
                  )
                  .slideY(
                    begin: 0.15,
                    end: 0,
                    duration: 600.ms,
                    delay: 150.ms,
                    curve: Curves.easeOut,
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Bottom Controls ─────────────────────────────────────────────────────────

class _BottomControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Color accentColor;
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const _BottomControls({
    required this.currentPage,
    required this.totalPages,
    required this.accentColor,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, bottomPadding + 24.h),
      decoration: const BoxDecoration(color: AppColors.darkBackground),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Page Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalPages, (index) {
              final isActive = index == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubic,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: isActive ? 28.w : 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  color: isActive
                      ? accentColor
                      : Colors.white.withValues(alpha: 0.2),
                ),
              );
            }),
          ),
          SizedBox(height: 28.h),

          // Continue Button
          SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.darkBackground,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    currentPage == totalPages - 1 ? 'Get Started' : 'Continue',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 500.ms, delay: 300.ms)
              .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 300.ms),
          SizedBox(height: 16.h),

          // Skip / Later
          GestureDetector(
            onTap: onSkip,
            child: Text(
              'Later',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.45),
                letterSpacing: 0.3,
              ),
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 450.ms),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}
