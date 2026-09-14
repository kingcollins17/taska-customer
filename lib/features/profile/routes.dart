import 'package:go_router/go_router.dart';
import 'package:seeker_app/core/routes/route_names.dart';
import 'presentation/profile_screen.dart';
import 'presentation/update_profiles_screen.dart';
import 'presentation/update_payout_account_screen.dart';
import 'presentation/payouts_list_screen.dart';

final List<RouteBase> profileRoutes = [
  GoRoute(
    path: '/profile-details',
    builder: (context, state) => const UpdateProfileScreen(),
  ),
  GoRoute(
    name: RouteNames.updatePayoutAccount.name,
    path: '/update-payout-account',
    builder: (context, state) => const UpdatePayoutAccountScreen(),
  ),
  GoRoute(
    name: RouteNames.payoutsList.name,
    path: '/payouts',
    builder: (context, state) => const PayoutsListScreen(),
  ),
];
