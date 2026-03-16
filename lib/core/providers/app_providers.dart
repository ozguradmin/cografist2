import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_service.dart';
import '../../services/hive_service.dart';
import '../../services/content_service.dart';
import '../../models/user_progress.dart';

// Auth stream
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseService.authState;
});

// Current user progress
final userProgressProvider = StateNotifierProvider<UserProgressNotifier, UserProgress>((ref) {
  final authState = ref.watch(authStateProvider);
  final uid = authState.valueOrNull?.uid ?? 'guest';
  return UserProgressNotifier(HiveService.getOrCreateProgress(uid));
});

class UserProgressNotifier extends StateNotifier<UserProgress> {
  UserProgressNotifier(UserProgress initial) : super(initial);

  void recordAnswer(bool correct) {
    state.recordAnswer(correct);
    state = state; // trigger rebuild
  }

  void changeExamMode(String mode) {
    state.examMode = mode;
    state.save();
    state = state;
  }

  void addBadge(String badgeId) {
    state.addBadge(badgeId);
    state = state;
  }

  void completeIl(String ilId) {
    state.completeIl(ilId);
    state = state;
  }
}

// Exam mode shortcut
final examModeProvider = Provider<String>((ref) {
  return ref.watch(userProgressProvider).examMode;
});

// Dark mode
final darkModeProvider = StateNotifierProvider<DarkModeNotifier, bool>((ref) {
  return DarkModeNotifier(HiveService.darkMode);
});

class DarkModeNotifier extends StateNotifier<bool> {
  DarkModeNotifier(bool initial) : super(initial);
  void toggle() {
    state = !state;
    HiveService.setDarkMode(state);
  }
}

// Content providers
final flashCardsProvider = FutureProvider.family<List<dynamic>, String>((ref, konu) async {
  final examMode = ref.watch(examModeProvider);
  return ContentService.instance.getFlashCards(sinav: examMode, konu: konu.isEmpty ? null : konu);
});

final questionsProvider = FutureProvider.family<List<dynamic>, String>((ref, konu) async {
  final examMode = ref.watch(examModeProvider);
  return ContentService.instance.getQuestions(sinav: examMode, konu: konu.isEmpty ? null : konu);
});

final illerProvider = FutureProvider((ref) async {
  return ContentService.instance.getIller();
});
