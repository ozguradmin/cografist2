import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cografist/core/theme/app_colors.dart';
import 'package:cografist/core/providers/app_providers.dart';
import 'package:cografist/shared/widgets/app_widgets.dart';
import 'package:cografist/models/badge_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // Greeting row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Merhaba 👋',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      ExamBadge(mode: progress.examMode),
                    ],
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      StreakPill(streak: progress.currentStreak),
                      const SizedBox(width: 8),
                      if (progress.currentStreak > 0)
                        Text(
                          'Serin devam ediyor!',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ).animate().fadeIn(delay: 50.ms, duration: 300.ms),

                  const SizedBox(height: 20),

                  // Daily goal card
                  DailyGoalCard(
                    answered: progress.todayAnswered,
                    goal: progress.dailyGoal,
                  ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 24),

                  Text('Modlar', style: Theme.of(context).textTheme.titleMedium)
                      .animate().fadeIn(delay: 150.ms),

                  const SizedBox(height: 12),

                  // Mode grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: const [
                      _ModeCard(emoji: '🗺️', name: 'Harita Modu',     desc: 'Türkiye\'yi keşfet', bg: AppColors.primaryLight, textColor: Color(0xFF3755E8), route: '/map'),
                      _ModeCard(emoji: '🃏', name: 'Flash Card',       desc: 'Hızlı tekrar',        bg: Color(0xFFFFF4E6),      textColor: Color(0xFFC05C00), route: '/flash'),
                      _ModeCard(emoji: '🎯', name: 'Günlük Sorular',   desc: 'Bugünkü sorular',     bg: Color(0xFFE8FFF4),      textColor: Color(0xFF0A6B3A), route: '/map'),
                      _ModeCard(emoji: '🔀', name: 'Karışık Çalış',   desc: 'Rastgele konu',        bg: Color(0xFFF3EEFF),      textColor: Color(0xFF5228A8), route: '/flash'),
                    ],
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                  const SizedBox(height: 24),

                  // Badges section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rozetler', style: Theme.of(context).textTheme.titleMedium),
                      GestureDetector(
                        onTap: () => context.go('/profile'),
                        child: Text('Tümünü gör →',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary, fontWeight: FontWeight.w500,
                            )),
                      ),
                    ],
                  ).animate().fadeIn(delay: 250.ms),

                  const SizedBox(height: 12),
                ]),
              ),
            ),

            // Badge horizontal list
            SliverToBoxAdapter(
              child: SizedBox(
                height: 88,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: AppBadges.all.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final badge   = AppBadges.all[i];
                    final earned  = ref.watch(userProgressProvider).earnedBadges.contains(badge.id);
                    return _BadgeItem(badge: badge, earned: earned);
                  },
                ),
              ).animate().fadeIn(delay: 300.ms),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text('Son Aktivite', style: Theme.of(context).textTheme.titleMedium)
                      .animate().fadeIn(delay: 350.ms),
                  const SizedBox(height: 12),
                  _RecentActivity().animate().fadeIn(delay: 400.ms),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String emoji, name, desc, route;
  final Color bg, textColor;
  const _ModeCard({
    required this.emoji, required this.name, required this.desc,
    required this.bg, required this.textColor, required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(name,  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
            Text(desc,  style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.75))),
          ],
        ),
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final BadgeModel badge;
  final bool earned;
  const _BadgeItem({required this.badge, required this.earned});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: earned ? badge.renk.withOpacity(0.15) : AppColors.border.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Text(badge.emoji,
                    style: TextStyle(fontSize: 26, color: earned ? null : Colors.transparent.withOpacity(0))),
                if (!earned)
                  Text(badge.emoji, style: TextStyle(fontSize: 26, color: Colors.grey.withOpacity(0.3))),
                if (!earned)
                  const Positioned(
                    right: -2, bottom: -2,
                    child: Icon(Icons.lock, size: 14, color: AppColors.textTertiary),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 54,
          child: Text(
            badge.ad,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: 10,
              color: earned ? AppColors.textSecondary : AppColors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = const [
      ('Karadeniz Bölgesi', '8/10 doğru', true),
      ('Büyük Göller',      '5/10 doğru', false),
      ('İklim Bölgeleri',   '9/10 doğru', true),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final (topic, score, good) = entry.value;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              border: i < items.length - 1
                  ? const Border(bottom: BorderSide(color: AppColors.border, width: 0.5))
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(topic, style: Theme.of(context).textTheme.labelMedium),
                Text(
                  score,
                  style: TextStyle(
                    fontSize: 12,
                    color: good ? AppColors.success : AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
