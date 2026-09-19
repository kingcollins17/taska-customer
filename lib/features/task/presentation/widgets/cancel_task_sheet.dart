import 'package:flutter/material.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/features/task/presentation/screens/cancel_task_screen.dart';

export 'package:seeker_app/features/task/presentation/screens/cancel_task_screen.dart';

class CancelTaskSheet {
  CancelTaskSheet._();

  static Future<T?> show<T>(BuildContext context, {required Task task}) {
    return CancelTaskScreen.navigate<T>(context, task: task);
  }
}
