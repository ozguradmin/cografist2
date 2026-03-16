import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Ana renkler
  static const primary      = Color(0xFF4F6AF5);
  static const primaryLight = Color(0xFFEEF0FE);
  static const secondary    = Color(0xFFFF6B6B);
  static const secondaryLight = Color(0xFFFFF0F0);

  // Nötr
  static const background   = Color(0xFFF8F9FF);
  static const surface      = Color(0xFFFFFFFF);
  static const textPrimary  = Color(0xFF1A1A2E);
  static const textSecondary= Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const border       = Color(0xFFE5E7EB);

  // Dark mode
  static const backgroundDark  = Color(0xFF0F0F1A);
  static const surfaceDark     = Color(0xFF1A1A2E);
  static const textPrimaryDark = Color(0xFFF1F5F9);
  static const borderDark      = Color(0xFF2D2D42);

  // 7 Bölge renkleri
  static const marmara     = Color(0xFF4F6AF5);
  static const ege         = Color(0xFFFF9F43);
  static const akdeniz     = Color(0xFFFF6B6B);
  static const icAnadolu   = Color(0xFF54A0FF);
  static const karadeniz   = Color(0xFF1DD1A1);
  static const doguAnadolu = Color(0xFF5F27CD);
  static const guneydogu   = Color(0xFFFFC312);

  // Anlamsal
  static const success = Color(0xFF0A8040);
  static const successLight = Color(0xFFE6FAF0);
  static const error   = Color(0xFFC0392B);
  static const errorLight  = Color(0xFFFEE9E9);
  static const streak  = Color(0xFFE55A00);
  static const streakLight = Color(0xFFFFF4E6);

  static Color bolgaRenk(String bolge) {
    switch (bolge.toLowerCase()) {
      case 'marmara':     return marmara;
      case 'ege':         return ege;
      case 'akdeniz':     return akdeniz;
      case 'ic_anadolu':  return icAnadolu;
      case 'karadeniz':   return karadeniz;
      case 'dogu_anadolu':return doguAnadolu;
      case 'guneydogu':   return guneydogu;
      default:            return primary;
    }
  }
}
