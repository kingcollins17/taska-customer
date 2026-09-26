import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Message type enum to drive distinct visual styles for each flushbar variant.
enum MessageType { info, error, success }

/// Visual style configuration for light or dark mode.
class _MessageStyle {
  final Color backgroundColor;
  final Color borderColor;
  final Color accentColor;
  final Color iconBgColor;
  final Color titleColor;
  final Color messageColor;

  const _MessageStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.accentColor,
    required this.iconBgColor,
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

/// Extension on [BuildContext] for showing beautifully styled, compact, theme-adaptive flushbar messages.
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
        backgroundColor: Color(0xFF0F172A),
        borderColor: Color(0xFF10B981),
        accentColor: Color(0xFF34D399),
        iconBgColor: Color(0xFF064E3B),
        titleColor: Colors.white,
        messageColor: Color(0xFFCBD5E1),
      ),
      lightStyle: _MessageStyle(
        backgroundColor: Colors.white,
        borderColor: Color(0xFFA7F3D0),
        accentColor: Color(0xFF059669),
        iconBgColor: Color(0xFFECFDF5),
        titleColor: Color(0xFF065F46),
        messageColor: Color(0xFF374151),
      ),
    ),
    MessageType.error: const _MessageConfig(
      icon: Icons.error_rounded,
      defaultTitle: 'Error',
      darkStyle: _MessageStyle(
        backgroundColor: Color(0xFF0F172A),
        borderColor: Color(0xFFF43F5E),
        accentColor: Color(0xFFFB7185),
        iconBgColor: Color(0xFF881337),
        titleColor: Colors.white,
        messageColor: Color(0xFFCBD5E1),
      ),
      lightStyle: _MessageStyle(
        backgroundColor: Colors.white,
        borderColor: Color(0xFFFECDD3),
        accentColor: Color(0xFFE11D48),
        iconBgColor: Color(0xFFFFF1F2),
        titleColor: Color(0xFF9F1239),
        messageColor: Color(0xFF374151),
      ),
    ),
    MessageType.info: const _MessageConfig(
      icon: Icons.info_rounded,
      defaultTitle: 'Notice',
      darkStyle: _MessageStyle(
        backgroundColor: Color(0xFF0F172A),
        borderColor: Color(0xFF3B82F6),
        accentColor: Color(0xFF60A5FA),
        iconBgColor: Color(0xFF1E3A8A),
        titleColor: Colors.white,
        messageColor: Color(0xFFCBD5E1),
      ),
      lightStyle: _MessageStyle(
        backgroundColor: Colors.white,
        borderColor: Color(0xFFBAE6FD),
        accentColor: Color(0xFF0284C7),
        iconBgColor: Color(0xFFF0F9FF),
        titleColor: Color(0xFF0369A1),
        messageColor: Color(0xFF374151),
      ),
    ),
  };

  /// Shows a compact, theme-adaptive floating flushbar message with the specified [type].
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
    final isDark = Theme.of(this).brightness == Brightness.dark;
    final config = _configs[type]!;
    final style = config.getStyle(isDark);
    final displayTitle = title ?? config.defaultTitle;

    late Flushbar flushbar;

    flushbar = Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      duration: duration,
      animationDuration: const Duration(milliseconds: 350),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      isDismissible: true,
      messageText: Container(
        decoration: BoxDecoration(
          color: style.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: style.borderColor.withValues(alpha: isDark ? 0.6 : 0.7),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: style.accentColor.withValues(alpha: isDark ? 0.25 : 0.12),
              blurRadius: 18,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
              blurRadius: 12,
              spreadRadius: -2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            // Icon Badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: style.iconBgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: style.accentColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  config.icon,
                  color: style.accentColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Title & Message Content
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (displayTitle.isNotEmpty) ...[
                    Text(
                      displayTitle,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: style.titleColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    message,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: style.messageColor,
                      height: 1.35,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Dismiss Button
            GestureDetector(
              onTap: () {
                flushbar.dismiss();
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    flushbar.show(this);
  }

  /// Shows a small, simple toast notification at the bottom of the screen.
  void showToast(
    String message, {
    MessageType type = MessageType.info,
    IconData? icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    final config = _configs[type]!;
    final style = config.getStyle(isDark);

    final toastBgColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFF0F172A);

    late Flushbar toastFlushbar;

    toastFlushbar = Flushbar(
      flushbarPosition: FlushbarPosition.BOTTOM,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      duration: duration,
      animationDuration: const Duration(milliseconds: 250),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      isDismissible: true,
      messageText: Container(
        decoration: BoxDecoration(
          color: toastBgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: style.accentColor.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? config.icon,
              color: style.accentColor,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );

    toastFlushbar.show(this);
  }
}
