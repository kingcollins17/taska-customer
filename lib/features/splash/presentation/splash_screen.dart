import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/services/local_storage_service.dart';
import 'package:seeker_app/core/utils/app_ready_manager.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // Master entrance sequence
  late final AnimationController _entranceController;
  late final Animation<double> _emblemScale;
  late final Animation<double> _emblemOpacity;
  late final Animation<double> _drawProgress;
  late final Animation<double> _ringExpand;
  late final Animation<double> _ringOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineSlide;

  // Continuous ambient rotation for outer graphic arcs
  late final AnimationController _rotationController;

  // Continuous ambient glow pulse
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  // Particle system
  late final AnimationController _particleController;

  // Exit animation
  late final AnimationController _exitController;
  late final Animation<double> _exitScale;
  late final Animation<double> _exitOpacity;

  // Particles list
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();

    // ── Entrance Animation (2.2s) ──
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _emblemScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );

    _emblemOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );

    _drawProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.1, 0.6, curve: Curves.easeInOutCubic),
      ),
    );

    _ringExpand = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _ringOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.7), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 0.7, end: 0.25), weight: 65),
    ]).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.6),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.45, 0.7, curve: Curves.easeOut),
      ),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.45, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.6, 0.85, curve: Curves.easeOut),
      ),
    );

    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.6, 0.85, curve: Curves.easeOutCubic),
          ),
        );

    // ── Continuous Arc Rotation ──
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    // ── Ambient Pulse ──
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // ── Floating Particles ──
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    final rng = math.Random(42);
    _particles = List.generate(35, (_) => _Particle.random(rng));

    // ── Exit Animation ──
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _exitScale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic),
    );

    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic),
    );

    // Start controllers
    _entranceController.forward();
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
    _particleController.repeat();

    // Delayed navigation sequence
    _scheduleNavigation();
  }

  void _scheduleNavigation() {
    const ms = 5000;
    Future.delayed(const Duration(milliseconds: ms), () async {
      if (!mounted) return;
      await _exitController.forward();
      if (!mounted) return;

      final isOnboardingComplete =
          await appStorage.get(StorageKey.onboardingComplete) == true;
      if (!mounted) return;

      if (!isOnboardingComplete) {
        context.go('/onboarding');
      } else {
        final accessToken = await appStorage.get(StorageKey.accessToken);
        final isAuthenticated =
            accessToken != null && accessToken.toString().isNotEmpty;
        if (!mounted) return;

        if (isAuthenticated) {
          context.go('/');
        } else {
          context.go('/login');
        }

        AppReadyManager.instance.markAsReady();
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _rotationController.dispose();
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
          _rotationController,
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
                  // Dynamic background gradient with ambient glow
                  _buildBackground(),

                  // Floating particle network
                  _buildParticles(),

                  // Center brand graphics & typography
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildCustomGraphicEmblem(),
                        SizedBox(height: 36.h),

                        // Title with glowing gradient text feel
                        SlideTransition(
                          position: _textSlide,
                          child: FadeTransition(
                            opacity: _textOpacity,
                            child: ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.white,
                                    AppColors.secondary.withValues(alpha: 0.9),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ).createShader(bounds);
                              },
                              child: Text(
                                'Taska',
                                style: GoogleFonts.inter(
                                  fontSize: 42.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 3.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),

                        // Tagline text
                        SlideTransition(
                          position: _taglineSlide,
                          child: FadeTransition(
                            opacity: _taglineOpacity,
                            child: Text(
                              'Find the right pro, right now.',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.5),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom shimmer loading bar
                  _buildBottomLoader(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackground() {
    return CustomPaint(
      painter: _BackgroundPainter(
        pulse: _pulseAnim.value,
        primaryColor: AppColors.primary,
        secondaryColor: AppColors.secondary,
        accentOrange: AppColors.accentOrange,
      ),
    );
  }

  Widget _buildParticles() {
    return CustomPaint(
      painter: _ParticlePainter(
        particles: _particles,
        progress: _particleController.value,
        accentColor: AppColors.secondary,
      ),
    );
  }

  Widget _buildCustomGraphicEmblem() {
    return SizedBox(
      width: 170.w,
      height: 170.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer expanding accent ring
          Transform.scale(
            scale: _ringExpand.value,
            child: Container(
              width: 165.w,
              height: 165.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.secondary.withValues(
                    alpha: _ringOpacity.value,
                  ),
                  width: 1.5.w,
                ),
              ),
            ),
          ),

          // Central glowing aura behind the graphic
          Transform.scale(
            scale: _pulseAnim.value,
            child: Container(
              width: 110.w,
              height: 110.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 45.r,
                    spreadRadius: 10.r,
                  ),
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.2),
                    blurRadius: 65.r,
                    spreadRadius: 15.r,
                  ),
                  BoxShadow(
                    color: AppColors.accentOrange.withValues(alpha: 0.1),
                    blurRadius: 85.r,
                    spreadRadius: 20.r,
                  ),
                ],
              ),
            ),
          ),

          // Custom Painted Animated Emblem
          FadeTransition(
            opacity: _emblemOpacity,
            child: ScaleTransition(
              scale: _emblemScale,
              child: SizedBox(
                width: 150.w,
                height: 150.w,
                child: CustomPaint(
                  painter: _TaskaEmblemPainter(
                    drawProgress: _drawProgress.value,
                    rotationAngle: _rotationController.value * 2 * math.pi,
                    pulse: _pulseAnim.value,
                    primaryColor: AppColors.primary,
                    secondaryColor: AppColors.secondary,
                    accentOrange: AppColors.accentOrange,
                  ),
                ),
              ),
            ),
          ),
        ],
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
            width: 56.w,
            height: 3.h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2.r),
              child: LinearProgressIndicator(
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.secondary.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Custom Emblem Painter ───────────────────────────────────────────────────

class _TaskaEmblemPainter extends CustomPainter {
  final double drawProgress;
  final double rotationAngle;
  final double pulse;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentOrange;

  _TaskaEmblemPainter({
    required this.drawProgress,
    required this.rotationAngle,
    required this.pulse,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentOrange,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Layer: Background Hexagonal Glass Shield
    _drawGlassShield(canvas, center, radius * 0.68);

    // 2. Layer: Outer Counter-Rotating Orbital Arcs
    _drawOrbitalArcs(canvas, center, radius * 0.88);

    // 3. Layer: Custom 'T' & Checkmark Brand Vector Path
    _drawBrandVectorPath(canvas, center, size);
  }

  void _drawGlassShield(Canvas canvas, Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * math.pi / 180;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Shield fill gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          primaryColor.withValues(alpha: 0.25),
          secondaryColor.withValues(alpha: 0.08),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(path, fillPaint);

    // Shield subtle border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        colors: [
          secondaryColor.withValues(alpha: 0.5),
          Colors.white.withValues(alpha: 0.1),
          accentOrange.withValues(alpha: 0.3),
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(path, borderPaint);
  }

  void _drawOrbitalArcs(Canvas canvas, Offset center, double radius) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);

    final rect = Rect.fromCircle(center: Offset.zero, radius: radius);

    // Arc 1 - Primary Teal Arc
    final arc1Paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          secondaryColor.withValues(alpha: 0.8),
          primaryColor.withValues(alpha: 0.1),
        ],
      ).createShader(rect);
    canvas.drawArc(rect, 0, math.pi * 0.75, false, arc1Paint);

    // Arc 2 - Accent Orange Arc
    final arc2Paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          accentOrange.withValues(alpha: 0.7),
          accentOrange.withValues(alpha: 0.05),
        ],
      ).createShader(rect);
    canvas.drawArc(rect, math.pi * 1.1, math.pi * 0.45, false, arc2Paint);

    // Orbital Nodes
    final nodeAngle = math.pi * 0.75;
    final nodeOffset = Offset(
      radius * math.cos(nodeAngle),
      radius * math.sin(nodeAngle),
    );

    final nodeGlow = Paint()
      ..color = secondaryColor.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(nodeOffset, 4, nodeGlow);

    final nodeCore = Paint()..color = Colors.white;
    canvas.drawCircle(nodeOffset, 2, nodeCore);

    canvas.restore();

    // Secondary Counter-rotating Dotted Outer Ring
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-rotationAngle * 0.6);

    final outerRect = Rect.fromCircle(center: Offset.zero, radius: radius * 1.08);
    final outerArcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.15);

    for (int i = 0; i < 12; i++) {
      canvas.drawArc(
        outerRect,
        i * (math.pi / 6),
        math.pi / 24,
        false,
        outerArcPaint,
      );
    }

    canvas.restore();
  }

  void _drawBrandVectorPath(Canvas canvas, Offset center, Size size) {
    // Construct the vector path representing stylized 'T' integrated into a Checkmark:
    // 1. Top bar of 'T': (cx - 24, cy - 20) -> (cx + 22, cy - 20)
    // 2. Stem down: (cx - 2, cy - 20) -> (cx - 2, cy + 12)
    // 3. Sweep checkmark: (cx - 14, cy + 2) -> (cx - 2, cy + 16) -> (cx + 24, cy - 10)

    final cx = center.dx;
    final cy = center.dy;

    // Top Bar Path
    final topBarPath = Path()
      ..moveTo(cx - 26, cy - 18)
      ..lineTo(cx + 24, cy - 18);

    // Stem & Checkmark continuous Path
    final checkmarkPath = Path()
      ..moveTo(cx - 2, cy - 18)
      ..lineTo(cx - 2, cy + 14)
      ..moveTo(cx - 18, cy + 2)
      ..lineTo(cx - 3, cy + 17)
      ..lineTo(cx + 26, cy - 12);

    final fullPath = Path()
      ..addPath(topBarPath, Offset.zero)
      ..addPath(checkmarkPath, Offset.zero);

    // Apply draw progress via PathMetrics
    final animatedPath = Path();
    for (final metric in fullPath.computeMetrics()) {
      final extractLength = metric.length * drawProgress;
      animatedPath.addPath(metric.extractPath(0, extractLength), Offset.zero);
    }

    // Glow effect behind main stroke
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = secondaryColor.withValues(alpha: 0.4 * pulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawPath(animatedPath, glowPaint);

    // Main Gradient Stroke
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = LinearGradient(
        colors: [
          secondaryColor,
          Colors.white,
          accentOrange,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(
        Rect.fromPoints(Offset(cx - 26, cy - 18), Offset(cx + 26, cy + 18)),
      );

    canvas.drawPath(animatedPath, strokePaint);

    // Render node circles at key vector points if progress complete
    if (drawProgress > 0.4) {
      final nodeOpacity = ((drawProgress - 0.4) / 0.6).clamp(0.0, 1.0);
      final nodes = [
        Offset(cx - 26, cy - 18),
        Offset(cx + 24, cy - 18),
        Offset(cx - 18, cy + 2),
        Offset(cx + 26, cy - 12),
      ];

      for (final n in nodes) {
        final nodeGlow = Paint()
          ..color = secondaryColor.withValues(alpha: 0.5 * nodeOpacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(n, 3.5, nodeGlow);

        final nodePaint = Paint()
          ..color = Colors.white.withValues(alpha: nodeOpacity);
        canvas.drawCircle(n, 2.0, nodePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TaskaEmblemPainter old) {
    return old.drawProgress != drawProgress ||
        old.rotationAngle != rotationAngle ||
        old.pulse != pulse;
  }
}

// ─── Background Painter ──────────────────────────────────────────────────────

class _BackgroundPainter extends CustomPainter {
  final double pulse;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentOrange;

  _BackgroundPainter({
    required this.pulse,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentOrange,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.44);

    // 1. Main Primary Radial Glow
    final primaryShader = RadialGradient(
      colors: [
        primaryColor.withValues(alpha: 0.18 * pulse),
        primaryColor.withValues(alpha: 0.05 * pulse),
        Colors.transparent,
      ],
      stops: const [0.0, 0.45, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.75));

    final primaryPaint = Paint()..shader = primaryShader;
    canvas.drawCircle(center, size.width * 0.75, primaryPaint);

    // 2. Secondary Teal Glow Highlight
    final tealShader = RadialGradient(
      colors: [
        secondaryColor.withValues(alpha: 0.10 * pulse),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.45));

    final tealPaint = Paint()..shader = tealShader;
    canvas.drawCircle(center, size.width * 0.45, tealPaint);

    // 3. Warm Orange Top Right Ambient Glow
    final warmCenter = Offset(size.width * 0.75, size.height * 0.28);
    final warmShader = RadialGradient(
      colors: [
        accentOrange.withValues(alpha: 0.07 * pulse),
        Colors.transparent,
      ],
    ).createShader(
      Rect.fromCircle(center: warmCenter, radius: size.width * 0.5),
    );

    final warmPaint = Paint()..shader = warmShader;
    canvas.drawCircle(warmCenter, size.width * 0.5, warmPaint);
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter old) => old.pulse != pulse;
}

// ─── Particle Model & Painter ────────────────────────────────────────────────

class _Particle {
  final double x;
  final double y;
  final double speed;
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
      speed: 0.25 + rng.nextDouble() * 0.75,
      radius: 1.0 + rng.nextDouble() * 2.2,
      opacity: 0.12 + rng.nextDouble() * 0.35,
      phase: rng.nextDouble() * math.pi * 2,
    );
  }
}

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
      final dx = math.cos(angle) * 16;
      final dy = math.sin(angle) * 14;

      final offset = Offset(p.x * size.width + dx, p.y * size.height + dy);

      final paint = Paint()
        ..color = accentColor.withValues(
          alpha: p.opacity * (0.4 + 0.6 * math.sin(angle)),
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(offset, p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => true;
}
