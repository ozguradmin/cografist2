import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cografist/core/theme/app_colors.dart';
import 'package:cografist/core/providers/app_providers.dart';
import 'package:cografist/services/hive_service.dart';

class ExamSelectScreen extends ConsumerStatefulWidget {
  const ExamSelectScreen({super.key});

  @override
  ConsumerState<ExamSelectScreen> createState() => _ExamSelectScreenState();
}

class _ExamSelectScreenState extends ConsumerState<ExamSelectScreen> {
  String _selected = 'yks';

  final _exams = const [
    _ExamOption(
      id: 'yks',
      name: 'YKS',
      fullName: 'Üniversite Sınavı',
      desc: 'Detaylı konu anlatımı, grafik yorumlama ve analiz soruları',
      icon: '🎓',
      depth: 3,
    ),
    _ExamOption(
      id: 'kpss',
      name: 'KPSS',
      fullName: 'Kamu Personel Sınavı',
      desc: 'Geniş kapsam, idari yapı ve bilgi odaklı sorular',
      icon: '🏛️',
      depth: 3,
    ),
    _ExamOption(
      id: 'lgs',
      name: 'LGS',
      fullName: 'Lise Giriş Sınavı',
      desc: 'Temel düzey, görsel ağırlıklı ve doğrudan sorular',
      icon: '📚',
      depth: 1,
    ),
  ];

  void _confirm() async {
    await HiveService.setExamMode(_selected);
    ref.read(userProgressProvider.notifier).changeExamMode(_selected);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'Hangi sınava\nhazırlanıyorsun?',
                style: Theme.of(context).textTheme.displayMedium,
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 8),
              Text(
                'İstediğin zaman profilden değiştirebilirsin',
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

              const SizedBox(height: 32),

              ...List.generate(_exams.length, (i) {
                final exam = _exams[i];
                final isSelected = exam.id == _selected;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => setState(() => _selected = exam.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryLight : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 2 : 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.15)
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(exam.icon, style: const TextStyle(fontSize: 26)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      exam.name,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: isSelected ? AppColors.primary : null,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      exam.fullName,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: isSelected
                                            ? AppColors.primary.withOpacity(0.7)
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  exam.desc,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Konu derinliği göstergesi
                                Row(
                                  children: [
                                    Text(
                                      'Konu derinliği: ',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    ...List.generate(3, (j) => Container(
                                      width: 16,
                                      height: 6,
                                      margin: const EdgeInsets.only(right: 3),
                                      decoration: BoxDecoration(
                                        color: j < exam.depth
                                            ? (isSelected ? AppColors.primary : AppColors.textSecondary)
                                            : AppColors.border,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 150 + i * 80)).slideY(begin: 0.15, end: 0);
              }),

              const Spacer(),
              ElevatedButton(
                onPressed: _confirm,
                child: const Text('Devam'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExamOption {
  final String id, name, fullName, desc, icon;
  final int depth;
  const _ExamOption({
    required this.id,
    required this.name,
    required this.fullName,
    required this.desc,
    required this.icon,
    required this.depth,
  });
}
