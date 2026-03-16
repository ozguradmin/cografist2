import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cografist/core/theme/app_colors.dart';
import 'package:cografist/core/providers/app_providers.dart';
import 'package:cografist/models/badge_model.dart';
import 'package:cografist/services/firebase_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress  = ref.watch(userProgressProvider);
    final authState = ref.watch(authStateProvider);
    final user      = authState.valueOrNull;

    final displayName = user?.displayName ?? user?.email?.split('@').first ?? 'Kullanıcı';
    final initials    = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  Text('Profil', style: Theme.of(context).textTheme.titleLarge)
                      .animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 20),

                  // User header
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          image: user?.photoURL != null
                              ? DecorationImage(
                                  image: NetworkImage(user!.photoURL!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: user?.photoURL == null
                            ? Center(
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(displayName, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? 'Misafir kullanıcı',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              progress.examMode.toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).animate().fadeIn(delay: 50.ms),

                  const SizedBox(height: 24),

                  // Stats grid
                  Text('İstatistikler', style: Theme.of(context).textTheme.titleMedium)
                      .animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 12),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.8,
                    children: [
                      _StatCard(value: '🔥 ${progress.currentStreak}',  label: 'Günlük seri',      color: AppColors.streakLight),
                      _StatCard(value: '${progress.totalQuestionsAnswered}',     label: 'Toplam soru',       color: AppColors.primaryLight),
                      _StatCard(value: '${progress.completedIller.length}/81',   label: 'Tamamlanan il',     color: AppColors.successLight),
                      _StatCard(value: '${progress.earnedBadges.length}',        label: 'Kazanılan rozet',   color: Color(0xFFF3EEFF)),
                    ],
                  ).animate().fadeIn(delay: 150.ms),

                  const SizedBox(height: 24),

                  Text('Rozetler', style: Theme.of(context).textTheme.titleMedium)
                      .animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 12),
                ]),
              ),
            ),

            // Badges grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final badge  = AppBadges.all[i];
                    final earned = progress.earnedBadges.contains(badge.id);
                    return _BadgeGridItem(badge: badge, earned: earned)
                        .animate().fadeIn(delay: Duration(milliseconds: 60 * i));
                  },
                  childCount: AppBadges.all.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:    4,
                  crossAxisSpacing:  10,
                  mainAxisSpacing:   10,
                  childAspectRatio:  0.8,
                ),
              ),
            ),

            // Settings
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text('Ayarlar', style: Theme.of(context).textTheme.titleMedium)
                      .animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 12),
                  _SettingsList(ref: ref).animate().fadeIn(delay: 350.ms),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final Color  color;
  const _StatCard({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22)),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _BadgeGridItem extends StatelessWidget {
  final BadgeModel badge;
  final bool       earned;
  const _BadgeGridItem({required this.badge, required this.earned});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showBadgeDetail(context),
      child: Column(
        children: [
          Container(
            width:  56,
            height: 56,
            decoration: BoxDecoration(
              color:        earned ? badge.renk.withOpacity(0.15) : AppColors.border.withOpacity(0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  badge.emoji,
                  style: TextStyle(
                    fontSize: 28,
                    color: earned ? null : Colors.grey.withOpacity(0.4),
                  ),
                ),
                if (!earned)
                  Positioned(
                    bottom: 2, right: 2,
                    child: Container(
                      width: 16, height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.textTertiary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock, size: 10, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge.ad,
            textAlign: TextAlign.center,
            maxLines:  2,
            style: TextStyle(
              fontSize: 10,
              color: earned ? AppColors.textSecondary : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _showBadgeDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text(badge.emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(badge.ad, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(badge.aciklama, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: earned ? AppColors.successLight : AppColors.border.withOpacity(0.3),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                earned ? '✓ Kazanıldı' : '🔒 Henüz kazanılmadı',
                style: TextStyle(
                  color: earned ? AppColors.success : AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SettingsList extends ConsumerWidget {
  final WidgetRef ref;
  const _SettingsList({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider);

    return Container(
      decoration: BoxDecoration(
        color:        Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          _SettingsTile(
            title: 'Sınav Modu',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ref.read(userProgressProvider).examMode.toUpperCase(),
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
              ],
            ),
            onTap: () => context.go('/exam-select'),
            isFirst: true,
          ),
          _SettingsTile(
            title: 'Dark Mode',
            trailing: Switch.adaptive(
              value:          darkMode,
              onChanged:      (_) => ref.read(darkModeProvider.notifier).toggle(),
              activeColor:    AppColors.primary,
            ),
          ),
          _SettingsTile(
            title:    'Bildirimler',
            trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
            onTap:    () {},
          ),
          _SettingsTile(
            title:    'Hesap Ayarları',
            trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
            onTap:    () {},
          ),
          _SettingsTile(
            title: 'Çıkış Yap',
            titleColor: AppColors.error,
            trailing: const Icon(Icons.chevron_right, color: AppColors.error, size: 20),
            isLast: true,
            onTap: () async {
              await FirebaseService.signOut();
              if (context.mounted) context.go('/auth');
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String    title;
  final Color?    titleColor;
  final Widget    trailing;
  final VoidCallback? onTap;
  final bool      isFirst, isLast;

  const _SettingsTile({
    required this.title,
    this.titleColor,
    required this.trailing,
    this.onTap,
    this.isFirst = false,
    this.isLast  = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: !isLast
              ? const Border(bottom: BorderSide(color: AppColors.border, width: 0.5))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: titleColor,
                fontSize: 15,
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
