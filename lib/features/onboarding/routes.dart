import 'package:go_router/go_router.dart';
import 'presentation/onboarding_screen.dart';

final List<RouteBase> onboardingRoutes = [
  GoRoute(
    path: '/onboarding',
    name: 'onboarding',
    builder: (context, state) => const OnboardingScreen(),
  ),
];
