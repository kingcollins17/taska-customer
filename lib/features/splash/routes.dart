import 'package:go_router/go_router.dart';
import 'presentation/splash_screen.dart';

final List<RouteBase> splashRoutes = [
  GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
];
