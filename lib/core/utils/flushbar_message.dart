import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Message type enum to drive distinct visual styles for each flushbar variant.
enum MessageType { info, error, success }

/// Visual style configuration for light or dark mode.
class _MessageStyle {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color titleColor;
  final Color messageColor;

  const _MessageStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.titleColor,
    required this.messageColor,
  });
}

/// Visual configuration for each [MessageType] supporting both light & dark themes.
class _MessageConfig {
  final _MessageStyle lightStyle;
  final _MessageStyle darkStyle;
  final IconData icon;
  final String defaultTitle;

  const _MessageConfig({
    required this.lightStyle,
    required this.darkStyle,
    required this.icon,
    required this.defaultTitle,
  });

  _MessageStyle getStyle(bool isDark) => isDark ? darkStyle : lightStyle;
}

/// Extension on [BuildContext] for showing beautifully styled, theme-adaptive flushbar messages.
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
      icon: Icons.check_circle_rounded,
      defaultTitle: 'Success',
      darkStyle: _MessageStyle(
        backgroundColor: Color(0xFF0D2818),
        borderColor: Color(0xFF22C55E),
        iconColor: Color(0xFF4ADE80),
        titleColor: Colors.white,
        messageColor: Color(0xD9FFFFFF),
      ),
      lightStyle: _MessageStyle(
        backgroundColor: Color(0xFFF0FDF4),
        borderColor: Color(0xFF86EFAC),
        iconColor: Color(0xFF16A34A),
        titleColor: Color(0xFF14532D),
        messageColor: Color(0xFF166534),
      ),
    ),
    MessageType.error: const _MessageConfig(
      icon: Icons.error_rounded,
      defaultTitle: 'Error',
      darkStyle: _MessageStyle(
        backgroundColor: Color(0xFF2D0A0A),
        borderColor: Color(0xFFEF4444),
        iconColor: Color(0xFFF87171),
        titleColor: Colors.white,
        messageColor: Color(0xD9FFFFFF),
      ),
      lightStyle: _MessageStyle(
        backgroundColor: Color(0xFFFEF2F2),
        borderColor: Color(0xFFFCA5A5),
        iconColor: Color(0xFFDC2626),
        titleColor: Color(0xFF7F1D1D),
        messageColor: Color(0xFF991B1B),
      ),
    ),
    MessageType.info: const _MessageConfig(
      icon: Icons.info_rounded,
      defaultTitle: 'Info',
      darkStyle: _MessageStyle(
        backgroundColor: Color(0xFF0A1628),
        borderColor: Color(0xFF6366F1),
        iconColor: Color(0xFF818CF8),
        titleColor: Colors.white,
        messageColor: Color(0xD9FFFFFF),
      ),
      lightStyle: _MessageStyle(
        backgroundColor: Color(0xFFEEF2FF),
        borderColor: Color(0xFFA5B4FC),
        iconColor: Color(0xFF4F46E5),
        titleColor: Color(0xFF312E81),
        messageColor: Color(0xFF3730A3),
      ),
    ),
  };

  /// Shows a flushbar message with the specified [type] adapted to current app theme.
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
    final isDark = Theme.of(this).colorScheme.brightness == Brightness.dark;
    final config = _configs[type]!;
    final style = config.getStyle(isDark);

    Flushbar(
      messageText: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: style.iconColor.withValues(alpha: isDark ? 0.15 : 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(config.icon, color: style.iconColor, size: 22),
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
                    color: style.titleColor,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: style.messageColor,
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
      backgroundColor: style.backgroundColor,
      borderColor: style.borderColor.withValues(alpha: isDark ? 0.4 : 0.5),
      borderWidth: 1.5,
      boxShadows: [
        BoxShadow(
          color: style.borderColor.withValues(alpha: isDark ? 0.15 : 0.1),
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
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
