import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../models/question.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../shared/utils/haptics.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  int _selectedLayer = 0;
  int _questionIndex = 0;
  int? _selectedOption;
  bool _answered = false;

  final _layers = const [
    'İller & Bölgeler',
    'Dağlar & Ovalar',
    'Göller & Denizler',
    'Akarsular',
    'Tarım & Bitki',
    'İklim & Toprak',
    'Karışık',
  ];

  final _layerKonuMap = const [
    'bolgeler',
    'daglar',
    'gol_deniz',
    'akarsular',
    'tarim',
    'iklim',
    '',
  ];

  List<Question> _questions = [];
  bool _loadingQ = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final examMode = ref.read(examModeProvider);
    final konu = _layerKonuMap[_selectedLayer];
    final qs = await ref.read(questionsProvider(konu).future);
    if (mounted) {
      setState(() {
        _questions    = List<Question>.from(qs)..shuffle();
        _questionIndex= 0;
        _selectedOption= null;
        _answered     = false;
        _loadingQ     = false;
      });
    }
  }

  void _selectLayer(int i) {
    setState(() {
      _selectedLayer  = i;
      _loadingQ       = true;
    });
    _loadQuestions();
  }

  void _selectOption(int idx) {
    if (_answered) return;
    final q = _questions[_questionIndex];
    final correct = idx == q.dogruIndex;
    setState(() {
      _selectedOption = idx;
      _answered       = true;
    });
    if (correct) {
      AppHaptics.success();
      ref.read(userProgressProvider.notifier).recordAnswer(true);
    } else {
      AppHaptics.error();
      ref.read(userProgressProvider.notifier).recordAnswer(false);
    }
  }

  void _nextQuestion() {
    if (_questionIndex < _questions.length - 1) {
      setState(() {
        _questionIndex++;
        _selectedOption = null;
        _answered       = false;
      });
    } else {
      setState(() {
        _questions.shuffle();
        _questionIndex  = 0;
        _selectedOption = null;
        _answered       = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Harita', style: Theme.of(context).textTheme.titleLarge),
                  ExamBadge(mode: ref.watch(examModeProvider)),
                ],
              ),
            ),

            // Layer chips
            ChipSelector(
              items: _layers,
              selected: _selectedLayer,
              onSelect: _selectLayer,
            ),

            const SizedBox(height: 12),

            // Map
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _TurkeyMapWidget(
                completedIller: ref.watch(userProgressProvider).completedIller,
              ),
            ),

            const SizedBox(height: 12),

            // Question card
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _loadingQ
                    ? const Center(child: CircularProgressIndicator())
                    : _questions.isEmpty
                        ? _EmptyState()
                        : _QuestionCard(
                            question:       _questions[_questionIndex],
                            selectedOption: _selectedOption,
                            answered:       _answered,
                            onSelect:       _selectOption,
                            onNext:         _nextQuestion,
                            current:        _questionIndex + 1,
                            total:          _questions.length,
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TurkeyMapWidget extends StatelessWidget {
  final List<String> completedIller;
  const _TurkeyMapWidget({required this.completedIller});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 200,
        color: const Color(0xFFE8EEFF),
        child: Stack(
          children: [
            // SVG harita — assets/maps/turkiye.svg
            // flutter_svg ile yükle, her ilin svgId'sine göre renk ver
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SvgPicture.asset(
                  'assets/maps/turkiye.svg',
                  fit: BoxFit.contain,
                  // colorFilter uygulama: SVG içinde her ilin id'si "il-{id}" formatında
                  // Production'da flutter_svg'nin DrawableRoot ile her path'e ayrı renk uygulanır
                  // Basit implementasyon:
                  placeholderBuilder: (ctx) => _FallbackMap(),
                ),
              ),
            ),

            // Tamamlanan il sayacı
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${completedIller.length}/81 il',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FallbackMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // SVG yüklenemezse gösterilen fallback harita widget'ı
    return CustomPaint(
      painter: _TurkeyPainter(),
    );
  }
}

class _TurkeyPainter extends CustomPainter {
  // 7 bölgeyi canvas üzerine basit dikdörtgenlerle temsil eder
  static const _regions = [
    (name: 'KARADENİZ',  color: AppColors.karadeniz,   rect: Rect.fromLTWH(0.10, 0.05, 0.80, 0.25)),
    (name: 'MARMARA',    color: AppColors.marmara,      rect: Rect.fromLTWH(0.02, 0.30, 0.22, 0.35)),
    (name: 'EGE',        color: AppColors.ege,          rect: Rect.fromLTWH(0.02, 0.65, 0.20, 0.30)),
    (name: 'AKDENİZ',    color: AppColors.akdeniz,      rect: Rect.fromLTWH(0.22, 0.68, 0.45, 0.27)),
    (name: 'İÇ ANADOLU', color: AppColors.icAnadolu,    rect: Rect.fromLTWH(0.22, 0.30, 0.40, 0.38)),
    (name: 'D. ANADOLU', color: AppColors.doguAnadolu,  rect: Rect.fromLTWH(0.62, 0.30, 0.35, 0.45)),
    (name: 'G.D.ANADOLU',color: AppColors.guneydogu,    rect: Rect.fromLTWH(0.62, 0.75, 0.35, 0.20)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final r in _regions) {
      final paint = Paint()..color = r.color.withOpacity(0.85);
      final rect  = Rect.fromLTWH(
        r.rect.left * size.width,   r.rect.top * size.height,
        r.rect.width * size.width,  r.rect.height * size.height,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), paint);

      final tp = TextPainter(
        text: TextSpan(
          text: r.name,
          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(rect.center.dx - tp.width / 2, rect.center.dy - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QuestionCard extends StatelessWidget {
  final Question question;
  final int? selectedOption;
  final bool answered;
  final void Function(int) onSelect;
  final VoidCallback onNext;
  final int current, total;

  const _QuestionCard({
    required this.question,
    required this.selectedOption,
    required this.answered,
    required this.onSelect,
    required this.onNext,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Soru $current/$total',
                  style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                question.konu,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(question.soruMetni, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15)),
          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.8,
            children: List.generate(question.secenekler.length, (i) {
              final isCorrect  = i == question.dogruIndex;
              final isSelected = i == selectedOption;
              Color bg, border, textColor;

              if (!answered) {
                bg        = AppColors.primaryLight;
                border    = Colors.transparent;
                textColor = AppColors.primary;
              } else if (isCorrect) {
                bg        = AppColors.successLight;
                border    = AppColors.success;
                textColor = AppColors.success;
              } else if (isSelected) {
                bg        = AppColors.errorLight;
                border    = AppColors.error;
                textColor = AppColors.error;
              } else {
                bg        = AppColors.border.withOpacity(0.3);
                border    = Colors.transparent;
                textColor = AppColors.textTertiary;
              }

              return GestureDetector(
                onTap: () => onSelect(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: border, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    question.secenekler[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor),
                  ),
                ),
              );
            }),
          ),

          if (answered) ...[
            const SizedBox(height: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selectedOption == question.dogruIndex
                    ? AppColors.successLight
                    : AppColors.errorLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    selectedOption == question.dogruIndex ? Icons.check_circle : Icons.cancel,
                    color: selectedOption == question.dogruIndex ? AppColors.success : AppColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedOption == question.dogruIndex
                          ? 'Doğru! ${question.aciklama}'
                          : 'Yanlış. Doğru cevap: ${question.dogruCevap}',
                      style: TextStyle(
                        fontSize: 13,
                        color: selectedOption == question.dogruIndex ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
              child: const Text('Sonraki Soru →'),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Text('📭', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('Bu katman için soru bulunamadı',
              style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
