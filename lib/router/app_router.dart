import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../features/onboarding/routes.dart';
import '../features/splash/routes.dart';
import '../features/auth/routes.dart';
import '../features/home/routes.dart';
import '../features/profile/routes.dart';
import '../features/task_creation/routes.dart';
import '../features/notifications/routes.dart';

class AppRoutes {
  AppRoutes._();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      ...splashRoutes,
      ...onboardingRoutes,
      ...authRoutes,
      ...homeRoutes,
      ...profileRoutes,
      ...taskCreationRoutes,
      ...notificationsRoutes,
    ],
  );

}
