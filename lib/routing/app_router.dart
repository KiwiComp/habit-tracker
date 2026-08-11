import 'package:go_router/go_router.dart';
import 'package:habit_tracker/create_activity/create_activity.dart';
import 'package:habit_tracker/habit_page/habit_page.dart';
import 'package:habit_tracker/habits_list/habits_list.dart';
import 'package:habit_tracker/routing/widgets/widgets.dart';
import 'package:habit_tracker/start_page/start_page.dart';
import 'package:habit_tracker/task_page/task_page.dart';
import 'package:habit_tracker/tasks_list/tasks_list.dart';

/// Builds the app's [GoRouter] — see `ROUTING.md` for the full navigation
/// model this implements.
///
/// A function rather than a shared singleton, so each `App` instance (each
/// widget test included) gets its own router with fresh navigation state.
GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ShellScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/', builder: (_, _) => const StartPage())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/habits',
                builder: (_, _) => const HabitsListPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/tasks', builder: (_, _) => const TasksListPage()),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/create',
        builder: (context, state) =>
            CreateActivityPage(initialType: state.extra! as ActivityType),
      ),
      GoRoute(
        path: '/habit/:id',
        builder: (context, state) => HabitPage(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/task/:id',
        builder: (context, state) => TaskPage(id: state.pathParameters['id']!),
      ),
    ],
  );
}
