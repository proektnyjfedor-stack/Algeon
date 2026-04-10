/// App Router -- GoRouter configuration for Algeon
///
/// Declarative routing with ShellRoute for tab navigation,
/// redirect logic for onboarding/auth, and deep link support.

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/main_screen.dart';
import '../theme/app_theme.dart';
import '../screens/home_tab.dart';
import '../screens/practice_tab.dart';
import '../screens/exams_tab.dart';
import '../screens/achievements_tab.dart';
import '../screens/profile_tab.dart';
import '../screens/task_screen.dart';
import '../screens/topic_intro_screen.dart';
import '../screens/summary_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/onboarding_welcome_screen.dart';
import '../screens/splash_screen.dart';
import '../models/task.dart';
import '../services/progress_service.dart';

/// Tab paths used by ShellRoute navigation.
class AppRoutes {
  AppRoutes._();

  static const String learn = '/learn';
  static const String practice = '/practice';
  static const String exams = '/exams';
  static const String achievements = '/achievements';
  static const String profile = '/profile';
  static const String topicIntro = '/learn/intro';
  static const String task = '/learn/topic';
  static const String exam = '/exam';
  static const String summary = '/summary';
  static const String auth = '/auth';
  static const String onboarding = '/onboarding';
  static const String splash = '/splash';
}

/// Resolves the bottom-nav / rail index from the current location.
int _indexFromLocation(String path) {
  if (path.startsWith(AppRoutes.practice)) return 1;
  if (path.startsWith(AppRoutes.exams)) return 2;
  if (path.startsWith(AppRoutes.achievements)) return 3;
  if (path.startsWith(AppRoutes.profile)) return 4;
  return 0; // /learn or fallback
}

/// Root navigator key — used for full-screen routes above the shell.
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Global router instance.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: false,

  // ------------------------------------------------------------------
  // Redirect logic
  // ------------------------------------------------------------------
  redirect: (BuildContext context, GoRouterState state) {
    final uri = state.uri;
    final path = uri.path;

    // Normalize trailing slash to keep route matching consistent.
    // Example: `/profile/` -> `/profile`
    if (path.length > 1 && path.endsWith('/')) {
      final normalized = uri.replace(
        path: path.substring(0, path.length - 1),
      );
      return normalized.toString();
    }

    // Already heading to splash -- allow.
    if (path == AppRoutes.splash) return null;

    // Already heading to onboarding -- allow.
    if (path == AppRoutes.onboarding) return null;

    // Already heading to auth -- allow.
    if (path == AppRoutes.auth) return null;

    // On web, Firebase is not configured yet -- skip auth entirely.
    if (!kIsWeb) {
      // Native: auth check would go here when AuthService is
      // integrated with GoRouter. For now we rely on the initial
      // screen logic in main.dart and only guard onboarding.
    }

    // Onboarding guard: redirect if not complete.
    if (!ProgressService.isOnboardingComplete()) {
      return AppRoutes.onboarding;
    }

    return null; // No redirect needed.
  },

  // ------------------------------------------------------------------
  // Routes
  // ------------------------------------------------------------------
  routes: <RouteBase>[
    // Shell route -- wraps tabs in MainScreen scaffold.
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        final index = _indexFromLocation(state.uri.path);
        return MainScreen(
          currentIndex: index,
          child: child,
        );
      },
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.learn,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeTab(),
          ),
        ),
        GoRoute(
          path: AppRoutes.practice,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PracticeTab(),
          ),
        ),
        GoRoute(
          path: AppRoutes.exams,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ExamsTab(),
          ),
        ),
        GoRoute(
          path: AppRoutes.achievements,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AchievementsTab(),
          ),
        ),
        GoRoute(
          path: AppRoutes.profile,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfileTab(),
          ),
        ),
        // Some hosts/redirects may keep a trailing slash; keep a route alias
        // to ensure the profile tab always renders.
        GoRoute(
          path: '${AppRoutes.profile}/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfileTab(),
          ),
        ),
      ],
    ),

    // Topic intro screen -- shows theory before tasks.
    GoRoute(
      path: AppRoutes.topicIntro,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        final topicName = data['name'] as String? ?? '';
        final tasks = data['tasks'] as List<Task>? ?? [];
        return NoTransitionPage(
          child: TopicIntroScreen(
            topicName: topicName,
            tasks: tasks,
          ),
        );
      },
    ),

    // Task screen -- receives data via GoRouter `extra`.
    GoRoute(
      path: AppRoutes.task,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        final topicName = data['name'] as String? ?? '';
        final tasks = data['tasks'] as List<Task>? ?? [];
        return NoTransitionPage(
          child: TaskScreen(
            topicName: topicName,
            tasks: tasks,
          ),
        );
      },
    ),

    // Exam screen -- full-screen, no shell.
    GoRoute(
      path: AppRoutes.exam,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        final grade = data['grade'] as int? ?? 5;
        final tasks = data['tasks'] as List<Task>? ?? [];
        final timeMinutes = data['timeMinutes'] as int? ?? 20;
        final variantId = data['variantId'] as String?;
        return NoTransitionPage(
          child: ExamScreen(
            grade: grade,
            tasks: tasks,
            timeMinutes: timeMinutes,
            variantId: variantId,
          ),
        );
      },
    ),

    // Summary screen -- receives a map of results via `extra`.
    GoRoute(
      path: AppRoutes.summary,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return NoTransitionPage(child: SummaryScreen.fromMap(data));
      },
    ),

    // Auth screen (standalone, no shell).
    GoRoute(
      path: AppRoutes.auth,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return const NoTransitionPage(child: AuthScreen());
      },
    ),

    // Onboarding screen (standalone, no shell).
    GoRoute(
      path: AppRoutes.onboarding,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return const NoTransitionPage(child: OnboardingWelcomeScreen());
      },
    ),

    // Splash screen (standalone, shown on app launch).
    GoRoute(
      path: AppRoutes.splash,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return const NoTransitionPage(child: SplashScreen());
      },
    ),
  ],
  errorBuilder: (context, state) {
    // Make routing issues visible instead of showing an empty tab.
    return Scaffold(
      backgroundColor: AppThemeColors.background(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Страница не найдена: ${state.uri}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppThemeColors.textPrimary(context),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  },
);
