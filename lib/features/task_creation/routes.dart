import 'package:go_router/go_router.dart';
import 'package:seeker_app/core/routes/route_names.dart';

import 'presentation/screens/category_selection_screen.dart';
import 'presentation/screens/service_selection_screen.dart';
import 'presentation/screens/task_description_screen.dart';
import 'presentation/screens/budget_screen.dart';
import 'presentation/screens/location_screen.dart';
import 'presentation/screens/schedule_screen.dart';
import 'presentation/screens/review_screen.dart';
import 'presentation/screens/success_attachments_screen.dart';

final List<RouteBase> taskCreationRoutes = [
  GoRoute(
    path: '/task-creation/category',
    name: RouteNames.taskCategory.name,
    builder: (context, state) => const CategorySelectionScreen(),
  ),
  GoRoute(
    path: '/task-creation/service',
    name: RouteNames.taskService.name,
    builder: (context, state) {
      final categoryId = state.uri.queryParameters['categoryId'];
      return ServiceSelectionScreen(categoryId: categoryId);
    },
  ),
  GoRoute(
    path: '/task-creation/description',
    name: RouteNames.taskDescription.name,
    builder: (context, state) => const TaskDescriptionScreen(),
  ),
  GoRoute(
    path: '/task-creation/budget',
    name: RouteNames.taskBudget.name,
    builder: (context, state) => const BudgetScreen(),
  ),
  GoRoute(
    path: '/task-creation/location',
    name: RouteNames.taskLocation.name,
    builder: (context, state) => const LocationScreen(),
  ),
  GoRoute(
    path: '/task-creation/schedule',
    name: RouteNames.taskSchedule.name,
    builder: (context, state) => const ScheduleScreen(),
  ),
  GoRoute(
    path: '/task-creation/review',
    name: RouteNames.taskReview.name,
    builder: (context, state) => const ReviewScreen(),
  ),
  GoRoute(
    path: '/task-creation/success',
    name: RouteNames.taskSuccess.name,
    builder: (context, state) => const SuccessAttachmentsScreen(),
  ),
];
