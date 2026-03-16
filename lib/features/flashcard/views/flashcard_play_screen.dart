import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import 'package:cografist/core/theme/app_colors.dart';
import 'package:cografist/core/providers/app_providers.dart';
import 'package:cografist/models/flash_card.dart';
import 'package:cografist/services/content_service.dart';
import 'package:cografist/services/hive_service.dart';
import 'package:cografist/shared/utils/haptics.dart';

class FlashCardPlayScreen extends ConsumerStatefulWidget {
  final String konu;
  const FlashCardPlayScreen({super.key, required this.konu});

  @override
  ConsumerState<FlashCardPlayScreen> createState() => _FlashCardPlayScreenState();
}

class _FlashCardPlayScreenState extends ConsumerState<FlashCardPlayScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double>    _flipAnimation;

  List<FlashCard> _cards = [];
  int  _currentIndex = 0;
  bool _isFlipped    = false;
  bool _loading      = true;

  // Swipe drag
  double _dragOffset    = 0;
  bool   _isDragging    = false;
  bool   _swipeDecided  = false;

  // Summary
  int _knewCount    = 0;
  int _dontKnowCount= 0;
  bool _showSummary = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _loadCards();
  }

  Future<void> _loadCards() async {
    final examMode = ref.read(examModeProvider);
    final cards = await ContentService.instance.getFlashCards(
      sinav: examMode,
      konu:  widget.konu,
    );
    // Bilinmeyenleri öne al
    final states     = HiveService.getAllFlashStates();
    final unknown    = cards.where((c) => states[c.id]?.knew != true).toList();
    final known      = cards.where((c) => states[c.id]?.knew == true).toList();
    final ordered    = [...unknown, ...known];
    if (mounted) setState(() { _cards = ordered; _loading = false; });
  }

  void _flip() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
      AppHaptics.light();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  Future<void> _rate(bool knew) async {
    final card  = _cards[_currentIndex];
    final state = HiveService.getFlashState(card.id)
      ..knew        = knew
      ..reviewCount = (HiveService.getFlashState(card.id).reviewCount) + 1
      ..lastReviewed= DateTime.now();
    await HiveService.saveFlashState(state);

    if (knew) {
      _knewCount++;
      AppHaptics.success();
    } else {
      _dontKnowCount++;
      AppHaptics.error();
    }
    ref.read(userProgressProvider.notifier).recordAnswer(knew);

    if (_currentIndex < _cards.length - 1) {
      _flipController.reset();
      setState(() {
        _currentIndex++;
        _isFlipped   = false;
        _dragOffset  = 0;
        _swipeDecided= false;
      });
    } else {
      setState(() => _showSummary = true);
    }
  }

  void _restartUnknown() {
    final states  = HiveService.getAllFlashStates();
    final unknown = _cards.where((c) => states[c.id]?.knew != true).toList()..shuffle();
    _flipController.reset();
    setState(() {
      _cards        = unknown.isEmpty ? _cards : unknown;
      _currentIndex = 0;
      _isFlipped    = false;
      _knewCount    = 0;
      _dontKnowCount= 0;
      _showSummary  = false;
      _dragOffset   = 0;
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_showSummary) return _buildSummary(context);

    if (_cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(ContentService.instance.konuAdi(widget.konu))),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('📭', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('Kart bulunamadı', style: Theme.of(context).textTheme.bodyMedium),
          ]),
        ),
      );
    }

    final card     = _cards[_currentIndex];
    final progress = (_currentIndex + 1) / _cards.length;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ContentService.instance.konuAdi(widget.konu),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    '${_currentIndex + 1}/${_cards.length}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),

              const SizedBox(height: 24),

              // Flash Card
              Expanded(
                child: GestureDetector(
                  onTap: _flip,
                  onHorizontalDragStart: (d) {
                    if (!_isFlipped) return;
                    setState(() { _isDragging = true; _swipeDecided = false; });
                  },
                  onHorizontalDragUpdate: (d) {
                    if (!_isDragging) return;
                    setState(() => _dragOffset += d.delta.dx);
                  },
                  onHorizontalDragEnd: (d) {
                    if (!_isDragging) return;
                    setState(() => _isDragging = false);
                    if (_dragOffset > 80) {
                      _rate(true);
                    } else if (_dragOffset < -80) {
                      _rate(false);
                    } else {
                      setState(() => _dragOffset = 0);
                    }
                  },
                  child: Transform.translate(
                    offset: Offset(_dragOffset, 0),
                    child: Transform.rotate(
                      angle: _dragOffset * 0.002,
                      child: AnimatedBuilder(
                        animation: _flipAnimation,
                        builder: (_, __) {
                          final angle = _flipAnimation.value * math.pi;
                          final showFront = angle < math.pi / 2;

                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(angle),
                            alignment: Alignment.center,
                            child: showFront
                                ? _CardFace(
                                    isFront:  true,
                                    question: card.soru,
                                    swipeOffset: _dragOffset,
                                  )
                                : Transform(
                                    transform: Matrix4.identity()..rotateY(math.pi),
                                    alignment: Alignment.center,
                                    child: _CardFace(
                                      isFront:     false,
                                      answer:      card.cevap,
                                      description: card.aciklama,
                                      swipeOffset: _dragOffset,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Hint
              AnimatedOpacity(
                opacity: _isFlipped ? 1.0 : 0.6,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _isFlipped
                      ? 'Sola kaydır: bilmiyorum  ·  Sağa kaydır: biliyorum'
                      : 'Cevabı görmek için karta dokun',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),

              const SizedBox(height: 16),

              // Action buttons
              AnimatedOpacity(
                opacity: _isFlipped ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 300),
                child: Row(
                  children: [
                    Expanded(
                      child: _RateButton(
                        label:   'Bilmiyorum',
                        icon:    Icons.close,
                        color:   AppColors.error,
                        bgColor: AppColors.errorLight,
                        onTap:   _isFlipped ? () => _rate(false) : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RateButton(
                        label:   'Biliyorum',
                        icon:    Icons.check,
                        color:   AppColors.success,
                        bgColor: AppColors.successLight,
                        onTap:   _isFlipped ? () => _rate(true) : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final total   = _knewCount + _dontKnowCount;
    final pct     = total > 0 ? (_knewCount / total * 100).round() : 0;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(pct >= 80 ? '🎉' : '💪', style: const TextStyle(fontSize: 72))
                    .animate().scale(duration: 500.ms, curve: Curves.elasticOut),

                const SizedBox(height: 24),

                Text(
                  pct >= 80 ? 'Harika gitti!' : 'İyi çalışma!',
                  style: Theme.of(context).textTheme.displayMedium,
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 8),

                Text(
                  '$total kartın tamamlandı',
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SummaryChip(count: _knewCount,     label: 'Biliyorum', color: AppColors.success),
                    const SizedBox(width: 16),
                    _SummaryChip(count: _dontKnowCount, label: 'Bilmiyorum', color: AppColors.error),
                  ],
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 48),

                if (_dontKnowCount > 0)
                  ElevatedButton(
                    onPressed: _restartUnknown,
                    child: Text('Bilmediklerimi tekrar et ($_dontKnowCount kart)'),
                  ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 12),

                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Konulara Dön'),
                ).animate().fadeIn(delay: 550.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final bool    isFront;
  final String? question, answer, description;
  final double  swipeOffset;

  const _CardFace({
    required this.isFront,
    this.question,
    this.answer,
    this.description,
    required this.swipeOffset,
  });

  @override
  Widget build(BuildContext context) {
    // Swipe renk tonu
    Color? tintColor;
    double tintOpacity = 0;
    if (!isFront) {
      if (swipeOffset > 30) {
        tintColor   = AppColors.success;
        tintOpacity = (swipeOffset / 200).clamp(0, 0.25);
      } else if (swipeOffset < -30) {
        tintColor   = AppColors.error;
        tintOpacity = (-swipeOffset / 200).clamp(0, 0.25);
      }
    }

    return Container(
      width:        double.infinity,
      decoration: BoxDecoration(
        color:        isFront ? AppColors.primary : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: isFront
            ? null
            : Border.all(color: AppColors.primary, width: 2),
      ),
      child: Stack(
        children: [
          // Swipe tint overlay
          if (tintColor != null)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color:        tintColor.withOpacity(tintOpacity),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),

          // Swipe indicator
          if (!isFront && swipeOffset.abs() > 40)
            Positioned(
              top: 20, right: swipeOffset > 0 ? 20 : null, left: swipeOffset < 0 ? 20 : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: swipeOffset > 0 ? AppColors.success : AppColors.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  swipeOffset > 0 ? 'Biliyorum ✓' : '✕ Bilmiyorum',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),

          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isFront ? 'SORU' : 'CEVAP',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isFront
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.textTertiary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isFront ? (question ?? '') : (answer ?? ''),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isFront ? 20 : 26,
                      fontWeight: FontWeight.w700,
                      color: isFront ? Colors.white : AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  if (!isFront && description != null && description!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      description!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                  if (isFront) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Cevabı görmek için dokun',
                      style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RateButton extends StatelessWidget {
  final String   label;
  final IconData icon;
  final Color    color, bgColor;
  final VoidCallback? onTap;

  const _RateButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color:        bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final int    count;
  final String label;
  final Color  color;

  const _SummaryChip({required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: color),
          ),
          Text(label, style: TextStyle(fontSize: 13, color: color)),
        ],
      ),
    );
  }
}
