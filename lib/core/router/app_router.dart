import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import 'package:cografist/services/hive_service.dart';
import 'package:cografist/features/onboarding/views/onboarding_screen.dart';
import 'package:cografist/features/auth/views/auth_screen.dart';
import 'package:cografist/features/auth/views/exam_select_screen.dart';
import 'package:cografist/features/home/views/home_screen.dart';
import 'package:cografist/features/map/views/map_screen.dart';
import 'package:cografist/features/flashcard/views/flashcard_list_screen.dart';
import 'package:cografist/features/flashcard/views/flashcard_play_screen.dart';
import 'package:cografist/features/profile/views/profile_screen.dart';
import 'package:cografist/shared/widgets/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: HiveService.onboardingDone ? '/home' : '/onboarding',
    redirect: (context, state) {
      final loggedIn  = authState.valueOrNull != null;
      final goingAuth = state.matchedLocation.startsWith('/auth') ||
                        state.matchedLocation.startsWith('/onboarding') ||
                        state.matchedLocation.startsWith('/exam-select');
      if (!loggedIn && !goingAuth) return '/auth';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (_, __) => const AuthScreen(),
      ),
      GoRoute(
        path: '/exam-select',
        builder: (_, __) => const ExamSelectScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home',    builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/map',     builder: (_, __) => const MapScreen()),
          GoRoute(
            path: '/flash',
            builder: (_, __) => const FlashCardListScreen(),
            routes: [
              GoRoute(
                path: ':konu',
                builder: (_, state) => FlashCardPlayScreen(
                  konu: state.pathParameters['konu']!,
                ),
              ),
            ],
          ),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
    ],
  );
});
