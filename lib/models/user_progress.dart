import 'package:hive/hive.dart';

part 'user_progress.g.dart';

@HiveType(typeId: 0)
class UserProgress extends HiveObject {
  @HiveField(0)
  String uid;

  @HiveField(1)
  String examMode; // 'yks' | 'kpss' | 'lgs'

  @HiveField(2)
  int currentStreak;

  @HiveField(3)
  int longestStreak;

  @HiveField(4)
  DateTime? lastStudyDate;

  @HiveField(5)
  int totalQuestionsAnswered;

  @HiveField(6)
  int totalCorrect;

  @HiveField(7)
  List<String> completedIller; // il id'leri

  @HiveField(8)
  List<String> completedBolgeler;

  @HiveField(9)
  List<String> earnedBadges; // rozet id'leri

  @HiveField(10)
  int dailyGoal;

  @HiveField(11)
  int todayAnswered;

  @HiveField(12)
  DateTime? todayDate;

  UserProgress({
    required this.uid,
    this.examMode = 'yks',
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastStudyDate,
    this.totalQuestionsAnswered = 0,
    this.totalCorrect = 0,
    List<String>? completedIller,
    List<String>? completedBolgeler,
    List<String>? earnedBadges,
    this.dailyGoal = 10,
    this.todayAnswered = 0,
    this.todayDate,
  })  : completedIller   = completedIller   ?? [],
        completedBolgeler= completedBolgeler ?? [],
        earnedBadges     = earnedBadges     ?? [];

  double get dailyProgress =>
      dailyGoal > 0 ? (todayAnswered / dailyGoal).clamp(0.0, 1.0) : 0.0;

  double get accuracy =>
      totalQuestionsAnswered > 0
          ? totalCorrect / totalQuestionsAnswered
          : 0.0;

  void recordAnswer(bool correct) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    // Günlük sıfırlama
    if (todayDate == null ||
        DateTime(todayDate!.year, todayDate!.month, todayDate!.day) != todayOnly) {
      todayAnswered = 0;
      todayDate = todayOnly;
    }

    todayAnswered++;
    totalQuestionsAnswered++;
    if (correct) totalCorrect++;

    // Streak güncelle
    if (lastStudyDate == null) {
      currentStreak = 1;
    } else {
      final lastOnly = DateTime(lastStudyDate!.year, lastStudyDate!.month, lastStudyDate!.day);
      final diff = todayOnly.difference(lastOnly).inDays;
      if (diff == 1) {
        currentStreak++;
      } else if (diff > 1) {
        currentStreak = 1;
      }
    }
    lastStudyDate = today;
    if (currentStreak > longestStreak) longestStreak = currentStreak;
    save();
  }

  void addBadge(String badgeId) {
    if (!earnedBadges.contains(badgeId)) {
      earnedBadges.add(badgeId);
      save();
    }
  }

  void completeIl(String ilId) {
    if (!completedIller.contains(ilId)) {
      completedIller.add(ilId);
      save();
    }
  }
}
