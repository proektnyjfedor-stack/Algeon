/// App Router -- GoRouter configuration for Algeon
///
/// Declarative routing with ShellRoute for tab navigation,
/// redirect logic for onboarding, and deep link support.
library;

import '../screens/study_hub_screen.dart';
import '../screens/formula_reference_screen.dart';
import '../screens/daily_exam_screen.dart';
import '../screens/library_screen.dart';
import '../screens/mock_exam_screen.dart';
import '../screens/diagnostic_screen.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/main_screen.dart';
import '../theme/app_theme.dart';
import '../screens/home_tab.dart';
import '../screens/practice_tab.dart';
import '../screens/achievements_tab.dart';
import '../screens/profile_tab.dart';
import '../screens/exams_tab.dart';
import '../screens/exam_session_screen.dart';
import '../screens/task_screen.dart';
import '../screens/topic_intro_screen.dart';
import '../screens/summary_screen.dart';
import '../screens/onboarding_welcome_screen.dart';
import '../models/task.dart';
import 'route_extra_codec.dart';
import '../services/language_service.dart';
import '../services/progress_service.dart';

/// Tab paths used by ShellRoute navigation.
class AppRoutes {
  AppRoutes._();

  static const String learn = '/learn';
  static const String practice = '/practice';
  static const String achievements = '/achievements';
  static const String profile = '/profile';
  static const String exams = '/exams';
  static const String topicIntro = '/learn/intro';
  static const String task = '/learn/topic';
  static const String summary = '/summary';
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

String _startupLocation = AppRoutes.learn;

/// Capture the address before the bootstrap's temporary Navigator can change it.
void configureStartupLocation(String location) {
  final uri = Uri.tryParse(location);
  if (uri != null && uri.path.startsWith('/') && uri.path != '/') {
    _startupLocation = uri.toString();
  }
}

/// Global router instance.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: _startupLocation,
  overridePlatformDefaultLocation: true,
  debugLogDiagnostics: false,
  extraCodec: const RouteExtraCodec(),

  // ------------------------------------------------------------------
  // Redirect logic
  // ------------------------------------------------------------------
  redirect: (BuildContext context, GoRouterState state) {
    final uri = state.uri;
    final path = uri.path;

    // Normalize trailing slash to keep route matching consistent.
    // Example: `/profile/` -> `/profile`
    if (path.length > 1 && path.endsWith('/')) {
      final normalized = uri.replace(path: path.substring(0, path.length - 1));
      return normalized.toString();
    }

    // Старые ссылки на заставку — сразу в приложение без экрана splash.
    if (path == AppRoutes.splash) {
      if (!ProgressService.isOnboardingComplete()) return AppRoutes.onboarding;
      return AppRoutes.learn;
    }

    // Already heading to onboarding -- allow.
    if (path == AppRoutes.onboarding) return null;
    if (path == '/auth') {
      if (!ProgressService.isOnboardingComplete()) return AppRoutes.onboarding;
      return AppRoutes.learn;
    }

    // Optional placeholder for platform-specific branch.
    if (!kIsWeb) {
      // Platform-specific redirect rules can be added here.
    }

    // Onboarding guard: redirect if not complete.
    if (!ProgressService.isOnboardingComplete()) {
      return AppRoutes.onboarding;
    }

    if (path == AppRoutes.task || path == AppRoutes.topicIntro) {
      final extra = state.extra;
      if (extra is! Map ||
          extra['tasks'] is! List ||
          (extra['tasks'] as List).whereType<Task>().isEmpty) {
        return AppRoutes.learn;
      }
    }
    if (path == AppRoutes.summary &&
        (state.extra is! Map || (state.extra as Map)['totalCount'] is! int)) {
      return AppRoutes.learn;
    }
    return null; // No redirect needed.
  },

  // ------------------------------------------------------------------
  // Routes
  // ------------------------------------------------------------------
  routes: <RouteBase>[
    GoRoute(
      path: '/library',
      builder: (context, state) =>
          LibraryScreen(savedOnly: state.uri.queryParameters['saved'] == '1'),
    ),
    GoRoute(
      path: '/study/run',
      builder: (context, state) => const DailyExamScreen(),
    ),
    GoRoute(
      path: '/formulas',
      builder: (context, state) => const FormulaReferenceScreen(),
    ),
    GoRoute(
      path: '/study',
      builder: (context, state) => StudyHubScreen(
        initialTab: int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0,
      ),
    ),
    GoRoute(
      path: '/diagnostic',
      builder: (context, state) => const DiagnosticScreen(),
    ),
    GoRoute(
      path: '/exams/:variantId/run',
      builder: (context, state) =>
          MockExamScreen(variantId: state.pathParameters['variantId']!),
    ),
    GoRoute(
      path: '/exams/:variantId',
      builder: (context, state) => ExamSessionScreen(
        variantId: state.pathParameters['variantId']!,
        initialQuestion: int.tryParse(
          state.uri.queryParameters['question'] ?? '',
        ),
        retry: state.uri.queryParameters['retry'] == '1',
      ),
    ),
    // Shell route -- wraps tabs in MainScreen scaffold.
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        final index = _indexFromLocation(state.uri.path);
        return MainScreen(currentIndex: index, child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/library',
          builder: (context, state) => LibraryScreen(
            savedOnly: state.uri.queryParameters['saved'] == '1',
          ),
        ),
        GoRoute(
          path: AppRoutes.learn,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomeTab()),
        ),
        GoRoute(
          path: AppRoutes.practice,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: PracticeTab()),
        ),
        GoRoute(
          path: AppRoutes.exams,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ExamsTab()),
        ),
        GoRoute(
          path: AppRoutes.achievements,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: AchievementsTab()),
        ),
        GoRoute(
          path: AppRoutes.profile,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ProfileTab()),
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
        final tasks =
            (data['tasks'] as List?)?.whereType<Task>().toList() ?? <Task>[];
        return NoTransitionPage(
          child: TopicIntroScreen(
            topicName: topicName,
            tasks: tasks,
            restart: data['restart'] == true,
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
        final tasks =
            (data['tasks'] as List?)?.whereType<Task>().toList() ?? <Task>[];
        return NoTransitionPage(
          child: TaskScreen(
            topicName: topicName,
            tasks: tasks,
            restart: data['restart'] == true,
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

    // Onboarding screen (standalone, no shell).
    GoRoute(
      path: AppRoutes.onboarding,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return const NoTransitionPage(child: OnboardingWelcomeScreen());
      },
    ),
  ],
  errorBuilder: (context, state) {
    final t = LanguageService.instance.t;
    return Scaffold(
      backgroundColor: AppThemeColors.background(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.travel_explore_rounded,
                  size: 56,
                  color: AppThemeColors.textHint(context),
                ),
                const SizedBox(height: 16),
                Text(
                  t('error.notFound'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppThemeColors.textPrimary(context),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${state.uri}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppThemeColors.textSecondary(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.learn),
                  icon: const Icon(Icons.home_rounded),
                  label: Text(t('error.toHome')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  },
);
