import 'package:hive/hive.dart';

part 'flash_card.g.dart';

@HiveType(typeId: 1)
class FlashCardState extends HiveObject {
  @HiveField(0)
  String cardId;

  @HiveField(1)
  bool knew;

  @HiveField(2)
  int reviewCount;

  @HiveField(3)
  DateTime? lastReviewed;

  FlashCardState({
    required this.cardId,
    this.knew = false,
    this.reviewCount = 0,
    this.lastReviewed,
  });
}

class FlashCard {
  final String id;
  final String konu;
  final String soru;
  final String cevap;
  final String aciklama;
  final String? gorsel;
  final int zorluk;
  final List<String> sinav;

  const FlashCard({
    required this.id,
    required this.konu,
    required this.soru,
    required this.cevap,
    required this.aciklama,
    this.gorsel,
    required this.zorluk,
    required this.sinav,
  });

  factory FlashCard.fromJson(Map<String, dynamic> j) => FlashCard(
        id:        j['id'],
        konu:      j['konu'],
        soru:      j['soru'],
        cevap:     j['cevap'],
        aciklama:  j['aciklama'],
        gorsel:    j['gorsel'],
        zorluk:    j['zorluk'] ?? 1,
        sinav:     List<String>.from(j['sinav'] ?? ['yks','kpss','lgs']),
      );
}
