import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cografist/core/theme/app_colors.dart';
import 'package:cografist/services/hive_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage  = 0;

  final _pages = const [
    _OnboardingPage(
      illustration: '🗺️',
      title: 'Coğrafist\'e\nHoş Geldin',
      subtitle: 'Türkiye coğrafyasını öğrenmenin\nen eğlenceli yolu',
      bgColor: AppColors.primaryLight,
    ),
    _OnboardingPage(
      illustration: '📍',
      title: 'Haritayı\nKeşfet',
      subtitle: '81 ili öğren, bölgeleri fethet,\ntüm coğrafi unsurları işaretle',
      bgColor: Color(0xFFE8FFF4),
    ),
    _OnboardingPage(
      illustration: '🎯',
      title: 'Sınavına\nGöre Çalış',
      subtitle: 'Hangi sınava hazırlandığını seç,\nsorular otomatik uyarlanır',
      bgColor: Color(0xFFFFF4E6),
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() async {
    await HiveService.setOnboardingDone();
    if (mounted) context.go('/exam-select');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, i) => _pages[i],
            ),

            // Skip button
            Positioned(
              top: 12,
              right: 20,
              child: TextButton(
                onPressed: _finish,
                child: const Text(
                  'Geç',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
              ),
            ),

            // Bottom controls
            Positioned(
              bottom: 32,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width:  i == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  // Button
                  ElevatedButton(
                    onPressed: _nextPage,
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'Başlayalım' : 'Devam',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String illustration;
  final String title;
  final String subtitle;
  final Color bgColor;

  const _OnboardingPage({
    required this.illustration,
    required this.title,
    required this.subtitle,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          // Illustration
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                illustration,
                style: const TextStyle(fontSize: 80),
              ),
            ),
          )
          .animate()
          .scale(duration: 400.ms, curve: Curves.elasticOut),

          const SizedBox(height: 40),

          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium,
          )
          .animate()
          .fadeIn(delay: 150.ms, duration: 400.ms)
          .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 16),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          )
          .animate()
          .fadeIn(delay: 250.ms, duration: 400.ms)
          .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}
