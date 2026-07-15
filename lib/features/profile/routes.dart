import 'package:go_router/go_router.dart';
import 'presentation/profile_screen.dart';
import 'presentation/profile_details_screen.dart';

final List<RouteBase> profileRoutes = [
  GoRoute(
    path: '/profile-details',
    builder: (context, state) => const ProfileDetailsScreen(),
  ),
];
