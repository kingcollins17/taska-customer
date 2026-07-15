import 'package:seeker_app/core/designs/app_colors.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeker_app/core/providers/user_provider.dart';
import 'package:seeker_app/core/services/local_storage_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // Master entrance sequence
  late final AnimationController _entranceController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _ringExpand;
  late final Animation<double> _ringOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineSlide;

  // Continuous ambient glow pulse
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  // Particle system
  late final AnimationController _particleController;

  // Exit animation
  late final AnimationController _exitController;
  late final Animation<double> _exitScale;
  late final Animation<double> _exitOpacity;

  // Particles
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();

    // ── Entrance (2.2 seconds) ──
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.35, curve: Curves.elasticOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
      ),
    );

    _ringExpand = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _ringOpacity =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.6), weight: 30),
          TweenSequenceItem(tween: Tween(begin: 0.6, end: 0.15), weight: 70),
        ]).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.15, 0.55),
          ),
        );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 0.6, curve: Curves.easeOut),
      ),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.4, 0.65, curve: Curves.easeOutCubic),
          ),
        );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.55, 0.75, curve: Curves.easeOut),
      ),
    );

    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.55, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    // ── Ambient Pulse ──
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // ── Particles ──
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    final rng = math.Random(42);
    _particles = List.generate(30, (_) => _Particle.random(rng));

    // ── Exit ──
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _exitScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic),
    );

    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic),
    );

    // ── Start sequence ──
    _entranceController.forward();
    _pulseController.repeat(reverse: true);
    _particleController.repeat();

    // Navigate after the splash plays
    Future.delayed(const Duration(milliseconds: 3200), () async {
      if (mounted) {
        await _exitController.forward();
        if (mounted) {
          final isOnboardingComplete =
              await appStorage.get(StorageKey.onboardingComplete) == true;
          if (!isOnboardingComplete) {
            context.go('/onboarding');
          } else {
            final isAuthenticated = await ref.read(
              isAuthenticatedProvider.future,
            );
            if (mounted) {
              if (isAuthenticated) {
                context.go('/');
              } else {
                context.go('/login');
              }
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkerBackground,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _entranceController,
          _pulseController,
          _particleController,
          _exitController,
        ]),
        builder: (context, _) {
          return FadeTransition(
            opacity: _exitOpacity,
            child: ScaleTransition(
              scale: _exitScale,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ── Background gradient ──
                  _buildBackground(),

                  // ── Floating particles ──
                  _buildParticles(),

                  // ── Center content ──
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo with ring
                        _buildLogoWithRing(),
                        SizedBox(height: 32.h),

                        // App Name
                        SlideTransition(
                          position: _textSlide,
                          child: FadeTransition(
                            opacity: _textOpacity,
                            child: Text(
                              'Taska',
                              style: GoogleFonts.inter(
                                fontSize: 38.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),

                        // Tagline
                        SlideTransition(
                          position: _taglineSlide,
                          child: FadeTransition(
                            opacity: _taglineOpacity,
                            child: Text(
                              'Find the right pro, right now.',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.45),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Bottom shimmer bar ──
                  _buildBottomLoader(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildBackground() {
    return CustomPaint(
      painter: _BackgroundPainter(
        pulse: _pulseAnim.value,
        accentColor: AppColors.accentPurple,
      ),
    );
  }

  Widget _buildLogoWithRing() {
    return SizedBox(
      width: 140.w,
      height: 140.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Expanding ring
          Transform.scale(
            scale: _ringExpand.value,
            child: Container(
              width: 140.w,
              height: 140.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accentPurple.withValues(
                    alpha: _ringOpacity.value,
                  ),
                  width: 2.w,
                ),
              ),
            ),
          ),

          // Ambient glow behind logo
          Transform.scale(
            scale: _pulseAnim.value,
            child: Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentPurple.withValues(alpha: 0.25),
                    blurRadius: 40.r,
                    spreadRadius: 8.r,
                  ),
                  BoxShadow(
                    color: AppColors.accentOrange.withValues(alpha: 0.08),
                    blurRadius: 60.r,
                    spreadRadius: 15.r,
                  ),
                ],
              ),
            ),
          ),

          // Logo image
          FadeTransition(
            opacity: _logoOpacity,
            child: ScaleTransition(
              scale: _logoScale,
              child: Container(
                width: 90.w,
                height: 90.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/app_logo.png'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentPurple.withValues(alpha: 0.3),
                      blurRadius: 20.r,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticles() {
    return CustomPaint(
      painter: _ParticlePainter(
        particles: _particles,
        progress: _particleController.value,
        accentColor: AppColors.accentPurple,
      ),
    );
  }

  Widget _buildBottomLoader() {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 48.h,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _taglineOpacity,
        child: Center(
          child: SizedBox(
            width: 48.w,
            height: 3.h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2.r),
              child: LinearProgressIndicator(
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.accentPurple.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Background Painter ──────────────────────────────────────────────────────

class _BackgroundPainter extends CustomPainter {
  final double pulse;
  final Color accentColor;

  _BackgroundPainter({required this.pulse, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);

    // Primary radial glow
    final primaryPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          accentColor.withValues(alpha: 0.12 * pulse),
          accentColor.withValues(alpha: 0.04 * pulse),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.7));
    canvas.drawCircle(center, size.width * 0.7, primaryPaint);

    // Warm secondary glow (offset)
    final warmCenter = Offset(size.width * 0.65, size.height * 0.38);
    final warmPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.accentOrange.withValues(alpha: 0.06 * pulse),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(center: warmCenter, radius: size.width * 0.4),
          );
    canvas.drawCircle(warmCenter, size.width * 0.4, warmPaint);
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter old) => old.pulse != pulse;
}

// ─── Particle Model ──────────────────────────────────────────────────────────

class _Particle {
  final double x; // 0..1
  final double y; // 0..1
  final double speed; // radians per cycle
  final double radius;
  final double opacity;
  final double phase;

  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.radius,
    required this.opacity,
    required this.phase,
  });

  factory _Particle.random(math.Random rng) {
    return _Particle(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      speed: 0.3 + rng.nextDouble() * 0.7,
      radius: 1.0 + rng.nextDouble() * 2.5,
      opacity: 0.15 + rng.nextDouble() * 0.35,
      phase: rng.nextDouble() * math.pi * 2,
    );
  }
}

// ─── Particle Painter ────────────────────────────────────────────────────────

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color accentColor;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final angle = progress * math.pi * 2 * p.speed + p.phase;
      final dx = math.cos(angle) * 18;
      final dy = math.sin(angle) * 12;

      final offset = Offset(p.x * size.width + dx, p.y * size.height + dy);

      final paint = Paint()
        ..color = accentColor.withValues(
          alpha: p.opacity * (0.5 + 0.5 * math.sin(angle)),
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(offset, p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => true;
}
