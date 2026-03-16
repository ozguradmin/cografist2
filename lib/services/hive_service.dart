import 'package:hive_flutter/hive_flutter.dart';
import 'package:cografist/models/user_progress.dart';
import 'package:cografist/models/flash_card.dart';

class HiveService {
  static const _progressBox    = 'user_progress';
  static const _flashStateBox  = 'flash_card_states';
  static const _settingsBox    = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserProgressAdapter());
    Hive.registerAdapter(FlashCardStateAdapter());
    await Hive.openBox<UserProgress>(_progressBox);
    await Hive.openBox<FlashCardState>(_flashStateBox);
    await Hive.openBox(_settingsBox);
  }

  // UserProgress
  static Box<UserProgress> get _progress => Hive.box<UserProgress>(_progressBox);

  static UserProgress getOrCreateProgress(String uid) {
    final existing = _progress.get(uid);
    if (existing != null) return existing;
    final fresh = UserProgress(uid: uid);
    _progress.put(uid, fresh);
    return fresh;
  }

  static Future<void> saveProgress(UserProgress p) async {
    await _progress.put(p.uid, p);
  }

  // FlashCard states
  static Box<FlashCardState> get _fcStates => Hive.box<FlashCardState>(_flashStateBox);

  static FlashCardState getFlashState(String cardId) {
    return _fcStates.get(cardId) ?? FlashCardState(cardId: cardId);
  }

  static Future<void> saveFlashState(FlashCardState state) async {
    await _fcStates.put(state.cardId, state);
  }

  static Map<String, FlashCardState> getAllFlashStates() {
    return Map.fromEntries(
      _fcStates.keys.map((k) => MapEntry(k as String, _fcStates.get(k)!)),
    );
  }

  // Settings
  static Box get _settings => Hive.box(_settingsBox);

  static bool get onboardingDone => _settings.get('onboarding_done', defaultValue: false);
  static Future<void> setOnboardingDone() async => _settings.put('onboarding_done', true);

  static String get examMode => _settings.get('exam_mode', defaultValue: 'yks');
  static Future<void> setExamMode(String mode) async => _settings.put('exam_mode', mode);

  static bool get darkMode => _settings.get('dark_mode', defaultValue: false);
  static Future<void> setDarkMode(bool val) async => _settings.put('dark_mode', val);
}
