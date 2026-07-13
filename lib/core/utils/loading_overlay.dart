import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// A beautifully animated loading overlay that uses Flutter's Overlay API
/// with a glassmorphism backdrop and SpinKit spinner.
///
/// Usage:
/// ```dart
/// context.showLoading();  // show overlay
/// context.hideLoading();  // dismiss
/// ```
class LoadingOverlayManager {
  LoadingOverlayManager._();

  static final LoadingOverlayManager _instance = LoadingOverlayManager._();
  static LoadingOverlayManager get instance => _instance;

  OverlayEntry? _overlayEntry;
  bool _isShowing = false;

  bool get isShowing => _isShowing;

  void show(BuildContext context) {
    // Prevent duplicate overlays
    if (_isShowing) return;

    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => const _LoadingOverlayWidget(),
    );

    overlay.insert(_overlayEntry!);
    _isShowing = true;
  }

  void hide() {
    if (!_isShowing) return;

    _overlayEntry?.remove();
    _overlayEntry = null;
    _isShowing = false;
  }
}

class _LoadingOverlayWidget extends StatefulWidget {
  const _LoadingOverlayWidget();

  @override
  State<_LoadingOverlayWidget> createState() => _LoadingOverlayWidgetState();
}

class _LoadingOverlayWidgetState extends State<_LoadingOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Dimmed backdrop
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.6)),
            ),
            // Centered spinner
            Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: const SpinKitThreeBounce(
                  color: Colors.white,
                  size: 30.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extension on [BuildContext] for convenient loading overlay access.
extension LoadingOverlayExtension on BuildContext {
  /// Shows a glassmorphism loading overlay with a SpinKit spinner.
  /// Call [hideLoading] to dismiss it.
  void showLoading() {
    LoadingOverlayManager.instance.show(this);
  }

  /// Hides the currently visible loading overlay.
  void hideLoading() {
    LoadingOverlayManager.instance.hide();
  }
}
