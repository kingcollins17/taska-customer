import 'package:go_router/go_router.dart';
import 'package:seeker_app/core/routes/route_names.dart';
import 'presentation/notifications_screen.dart';

final List<RouteBase> notificationsRoutes = [
  GoRoute(
    path: '/notifications',
    name: RouteNames.notifications.name,
    builder: (context, state) => const NotificationsScreen(),
  ),
];
