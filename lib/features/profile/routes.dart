import 'package:go_router/go_router.dart';
import 'package:seeker_app/core/routes/route_names.dart';
import 'presentation/profile_screen.dart';
import 'presentation/profile_details_screen.dart';
import 'presentation/update_payout_account_screen.dart';

final List<RouteBase> profileRoutes = [
  GoRoute(
    path: '/profile-details',
    builder: (context, state) => const ProfileDetailsScreen(),
  ),
  GoRoute(
    name: RouteNames.updatePayoutAccount.name,
    path: '/update-payout-account',
    builder: (context, state) => const UpdatePayoutAccountScreen(),
  ),
];
