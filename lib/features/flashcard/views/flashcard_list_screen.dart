import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../services/content_service.dart';
import '../../../services/hive_service.dart';

class FlashCardListScreen extends ConsumerWidget {
  const FlashCardListScreen({super.key});

  static const _konular = [
    'bolgeler', 'daglar', 'gol_deniz', 'akarsular', 'tarim', 'iklim',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examMode = ref.watch(examModeProvider);
    final cs = ContentService.instance;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Flash Kartlar', style: Theme.of(context).textTheme.titleLarge),
                    ExamModeBadge(mode: examMode),
                  ],
                ).animate().fadeIn(duration: 300.ms),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final konu = _konular[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TopicTile(
                        konu:     konu,
                        examMode: examMode,
                        onTap:    () => context.go('/flash/$konu'),
                      ).animate().fadeIn(delay: Duration(milliseconds: 80 * i), duration: 350.ms)
                       .slideY(begin: 0.1, end: 0),
                    );
                  },
                  childCount: _konular.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicTile extends ConsumerWidget {
  final String konu, examMode;
  final VoidCallback onTap;

  const _TopicTile({required this.konu, required this.examMode, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(flashCardsProvider(konu));
    final cs         = ContentService.instance;
    final allStates  = HiveService.getAllFlashStates();

    return cardsAsync.when(
      loading: () => _TileSkeleton(),
      error:   (_, __) => const SizedBox.shrink(),
      data: (cards) {
        final total    = cards.length;
        final knew     = cards.where((c) => allStates[c.id]?.knew == true).length;
        final progress = total > 0 ? knew / total : 0.0;
        final isDone   = progress >= 1.0;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDone ? AppColors.success.withOpacity(0.4) : AppColors.border,
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppColors.successLight
                        : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(cs.konuEmoji(konu), style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cs.konuAdi(konu),
                          style: Theme.of(context).textTheme.labelMedium),
                      const SizedBox(height: 2),
                      Text(
                        '$total kart · ${total - knew} bilinmiyor',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation(
                            isDone ? AppColors.success : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Done indicator or arrow
                if (isDone)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.successLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 16, color: AppColors.success),
                  )
                else
                  const Icon(Icons.chevron_right, color: AppColors.textTertiary),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TileSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.border.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}

class ExamModeBadge extends StatelessWidget {
  final String mode;
  const ExamModeBadge({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        mode.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}
