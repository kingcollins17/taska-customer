import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/routes/route_names.dart';
import 'presentation/main_layout.dart';
import 'presentation/home_screen.dart';
import '../profile/presentation/profile_screen.dart';
import '../task/presentation/screens/tasks_screen.dart';

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
            path: '/tasks',
            name: RouteNames.tasks.name,
            builder: (context, state) {
              List<String>? initialStatuses;
              final queryStatuses = state.uri.queryParameters['statuses'] ??
                  state.uri.queryParameters['status'];
              if (queryStatuses != null && queryStatuses.isNotEmpty) {
                initialStatuses = queryStatuses
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList();
              } else if (state.uri.queryParametersAll['statuses'] != null) {
                initialStatuses = state.uri.queryParametersAll['statuses'];
              }

              initialStatuses ??= state.extra is List<String>
                  ? state.extra as List<String>
                  : (state.extra is List
                      ? (state.extra as List).cast<String>()
                      : null);

              return TasksScreen(initialStatuses: initialStatuses);
            },
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  ),
];
