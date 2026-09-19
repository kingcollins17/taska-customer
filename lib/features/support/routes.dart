import 'package:go_router/go_router.dart';
import 'package:seeker_app/core/routes/route_names.dart';
import 'presentation/screens/create_support_case_screen.dart';
import 'presentation/screens/support_case_detail_screen.dart';
import 'presentation/screens/support_cases_list_screen.dart';
import 'presentation/screens/support_chat_screen.dart';

final List<RouteBase> supportRoutes = [
  GoRoute(
    name: RouteNames.createSupportCase.name,
    path: '/create-support-case',
    builder: (context, state) {
      final taskId = state.uri.queryParameters['taskId'];
      final assignmentId = state.uri.queryParameters['assignmentId'];
      final payoutId = state.uri.queryParameters['payoutId'];
      final type = state.uri.queryParameters['type'];
      final subject = state.uri.queryParameters['subject'];
      final description = state.uri.queryParameters['description'];

      return CreateSupportCaseScreen(
        taskId: taskId,
        assignmentId: assignmentId,
        payoutId: payoutId,
        type: type,
        subject: subject,
        description: description,
      );
    },
  ),
  GoRoute(
    name: RouteNames.supportCasesList.name,
    path: '/support-cases',
    builder: (context, state) => const SupportCasesListScreen(),
  ),
  GoRoute(
    name: RouteNames.supportCaseDetail.name,
    path: '/support-cases/:caseId',
    builder: (context, state) {
      final caseId = state.pathParameters['caseId']!;
      return SupportCaseDetailScreen(caseId: caseId);
    },
  ),
  GoRoute(
    name: RouteNames.supportChat.name,
    path: '/support-chat/:caseId',
    builder: (context, state) {
      final caseId = state.pathParameters['caseId']!;
      return SupportChatScreen(caseId: caseId);
    },
  ),
];
