import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Message type enum to drive distinct visual styles for each flushbar variant.
enum MessageType { info, error, success }

/// Visual configuration for each [MessageType].
class _MessageConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color progressColor;
  final IconData icon;
  final String defaultTitle;

  const _MessageConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.progressColor,
    required this.icon,
    required this.defaultTitle,
  });
}

/// Extension on [BuildContext] for showing beautifully styled flushbar messages.
///
/// Usage:
/// ```dart
/// context.showMessage('Task saved successfully!', type: MessageType.success);
/// context.showMessage('Check your connection', type: MessageType.error);
/// context.showMessage('New update available', type: MessageType.info);
/// ```
extension FlushbarMessageExtension on BuildContext {
  static final Map<MessageType, _MessageConfig> _configs = {
    MessageType.success: const _MessageConfig(
      backgroundColor: Color(0xFF0D2818),
      borderColor: Color(0xFF22C55E),
      iconColor: Color(0xFF4ADE80),
      progressColor: Color(0xFF22C55E),
      icon: Icons.check_circle_rounded,
      defaultTitle: 'Success',
    ),
    MessageType.error: const _MessageConfig(
      backgroundColor: Color(0xFF2D0A0A),
      borderColor: Color(0xFFEF4444),
      iconColor: Color(0xFFF87171),
      progressColor: Color(0xFFEF4444),
      icon: Icons.error_rounded,
      defaultTitle: 'Error',
    ),
    MessageType.info: const _MessageConfig(
      backgroundColor: Color(0xFF0A1628),
      borderColor: Color(0xFF6366F1),
      iconColor: Color(0xFF818CF8),
      progressColor: Color(0xFF6366F1),
      icon: Icons.info_rounded,
      defaultTitle: 'Info',
    ),
  };

  /// Shows a flushbar message with the specified [type].
  ///
  /// - [message] – The main body text of the flushbar.
  /// - [type] – One of [MessageType.info], [MessageType.error], or [MessageType.success].
  /// - [title] – Optional custom title; defaults based on [type].
  /// - [duration] – How long the flushbar stays visible. Defaults to 3 seconds.
  void showMessage(
    String message, {
    MessageType type = MessageType.info,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    final config = _configs[type]!;

    Flushbar(
      messageText: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: config.iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(config.icon, color: config.iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title ?? config.defaultTitle,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      duration: duration,
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      borderRadius: BorderRadius.circular(16),
      backgroundColor: config.backgroundColor,
      borderColor: config.borderColor.withValues(alpha: 0.4),
      borderWidth: 1.5,
      boxShadows: [
        BoxShadow(
          color: config.borderColor.withValues(alpha: 0.15),
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 12,
          spreadRadius: -2,
          offset: const Offset(0, 2),
        ),
      ],
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      animationDuration: const Duration(milliseconds: 500),
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      isDismissible: true,
    ).show(this);
  }
}
