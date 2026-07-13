import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import 'presentation/main_layout.dart';
import 'presentation/home_screen.dart';

final List<RouteBase> homeRoutes = [
  StatefulShellRoute.indexedStack(
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state, navigationShell) {
      return MainLayout(navigationShell: navigationShell);
    },
    branches: [
      StatefulShellBranch(
        navigatorKey: shellNavigatorKey,
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/messages',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Messages'))),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/calendar',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Calendar'))),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/profile',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Profile'))),
          ),
        ],
      ),
    ],
  ),
];
