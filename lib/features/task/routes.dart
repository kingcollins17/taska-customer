import 'package:go_router/go_router.dart';
import 'package:seeker_app/core/routes/route_names.dart';

import 'presentation/screens/category_selection_screen.dart';
import 'presentation/screens/service_selection_screen.dart';
import 'presentation/screens/task_description_screen.dart';
import 'presentation/screens/location_screen.dart';
import 'presentation/screens/schedule_screen.dart';
import 'presentation/screens/review_screen.dart';
import 'presentation/screens/success_screen.dart';
import 'presentation/screens/matching_screen.dart';
import 'presentation/screens/task_detail_screen.dart';

final List<RouteBase> taskRoutes = [
  GoRoute(
    path: '/task/detail/:taskId',
    name: RouteNames.taskDetail.name,
    builder: (context, state) {
      final taskId = state.pathParameters['taskId']!;
      return TaskDetailScreen(taskId: taskId);
    },
  ),
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
    builder: (context, state) {
      final params = state.uri.queryParameters;

      return TaskDescriptionScreen(
        initialTitle:
            params['title'] ?? params['initialTitle'] ?? params['service'],
      );
    },
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
    builder: (context, state) => const SuccessScreen(),
  ),
  GoRoute(
    path: '/task-creation/matching/:taskId',
    name: RouteNames.taskMatching.name,
    builder: (context, state) {
      final taskId = state.pathParameters['taskId']!;
      return MatchingScreen(taskId: taskId);
    },
  ),
];
