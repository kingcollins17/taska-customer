import 'package:flutter/material.dart';

class NotificationIcon extends StatelessWidget {
  final String type;

  const NotificationIcon({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;
    Color backgroundColor;

    switch (type) {
      case 'task_accepted':
      case 'prescription_ready':
        iconData = Icons.receipt_long;
        iconColor = Colors.green;
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        break;
      case 'priority':
        iconData = Icons.flag;
        iconColor = Colors.red;
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        break;
      case 'payment_required':
        iconData = Icons.payment;
        iconColor = Colors.teal;
        backgroundColor = Colors.teal.withValues(alpha: 0.1);
        break;
      case 'welcome':
        iconData = Icons.person;
        iconColor = Colors.blue;
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        break;
      case 'otp_success':
        iconData = Icons.lock;
        iconColor = Colors.purple;
        backgroundColor = Colors.purple.withValues(alpha: 0.1);
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Theme.of(context).colorScheme.primary;
        backgroundColor = Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
      ),
    );
  }
}
