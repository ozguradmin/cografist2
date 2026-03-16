import 'package:flutter/material.dart';
import 'package:cografist/core/theme/app_colors.dart';

enum BadgeCategory { il, bolge, konu, ozel }

class BadgeModel {
  final String id;
  final String ad;
  final String aciklama;
  final String emoji;
  final BadgeCategory kategori;
  final Color renk;

  const BadgeModel({
    required this.id,
    required this.ad,
    required this.aciklama,
    required this.emoji,
    required this.kategori,
    required this.renk,
  });
}

class AppBadges {
  static const List<BadgeModel> all = [
    BadgeModel(
      id: 'bolge_karadeniz',
      ad: 'Karadeniz Fatihi',
      aciklama: 'Karadeniz Bölgesi\'ni tamamla',
      emoji: '🌊',
      kategori: BadgeCategory.bolge,
      renk: AppColors.karadeniz,
    ),
    BadgeModel(
      id: 'bolge_marmara',
      ad: 'Marmara Ustası',
      aciklama: 'Marmara Bölgesi\'ni tamamla',
      emoji: '🏙️',
      kategori: BadgeCategory.bolge,
      renk: AppColors.marmara,
    ),
    BadgeModel(
      id: 'bolge_ege',
      ad: 'Ege Gezgini',
      aciklama: 'Ege Bölgesi\'ni tamamla',
      emoji: '🫒',
      kategori: BadgeCategory.bolge,
      renk: AppColors.ege,
    ),
    BadgeModel(
      id: 'bolge_akdeniz',
      ad: 'Akdeniz Kaşifi',
      aciklama: 'Akdeniz Bölgesi\'ni tamamla',
      emoji: '☀️',
      kategori: BadgeCategory.bolge,
      renk: AppColors.akdeniz,
    ),
    BadgeModel(
      id: 'bolge_ic',
      ad: 'Bozkır Yolcusu',
      aciklama: 'İç Anadolu Bölgesi\'ni tamamla',
      emoji: '🌾',
      kategori: BadgeCategory.bolge,
      renk: AppColors.icAnadolu,
    ),
    BadgeModel(
      id: 'bolge_dogu',
      ad: 'Doğu Biliği',
      aciklama: 'Doğu Anadolu Bölgesi\'ni tamamla',
      emoji: '🏔️',
      kategori: BadgeCategory.bolge,
      renk: AppColors.doguAnadolu,
    ),
    BadgeModel(
      id: 'bolge_guneydogu',
      ad: 'Güneydoğu Ustası',
      aciklama: 'Güneydoğu Anadolu Bölgesi\'ni tamamla',
      emoji: '🌅',
      kategori: BadgeCategory.bolge,
      renk: AppColors.guneydogu,
    ),
    BadgeModel(
      id: 'streak_7',
      ad: '7 Günlük Seri',
      aciklama: '7 gün üst üste çalış',
      emoji: '🔥',
      kategori: BadgeCategory.ozel,
      renk: Color(0xFFE55A00),
    ),
    BadgeModel(
      id: 'streak_30',
      ad: 'Sürekli',
      aciklama: '30 gün üst üste çalış',
      emoji: '⚡',
      kategori: BadgeCategory.ozel,
      renk: Color(0xFFE55A00),
    ),
    BadgeModel(
      id: 'haritaci',
      ad: 'Haritacı',
      aciklama: 'Türkiye\'nin tüm 81 ilini tamamla',
      emoji: '🗺️',
      kategori: BadgeCategory.ozel,
      renk: AppColors.primary,
    ),
    BadgeModel(
      id: 'yedi_bolge',
      ad: '7 Bölge',
      aciklama: 'Tüm 7 coğrafi bölgeyi tamamla',
      emoji: '👑',
      kategori: BadgeCategory.ozel,
      renk: AppColors.primary,
    ),
    BadgeModel(
      id: 'cilgin_cografist',
      ad: 'Çılgın Coğrafist',
      aciklama: 'Tüm 7 katmanı tamamla',
      emoji: '🌍',
      kategori: BadgeCategory.ozel,
      renk: AppColors.secondary,
    ),
  ];

  static BadgeModel? findById(String id) {
    try {
      return all.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}
