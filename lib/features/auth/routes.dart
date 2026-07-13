import 'package:go_router/go_router.dart';
import 'presentation/login_screen.dart';
import 'presentation/register_screen.dart';

final List<RouteBase> authRoutes = [
  GoRoute(
    path: '/login',
    name: 'login',
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: '/register',
    name: 'register',
    builder: (context, state) => const RegisterScreen(),
  ),
];
