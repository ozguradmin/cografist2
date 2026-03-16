# Coğrafist 🗺️

Türkiye coğrafyasını öğrenmenin en eğlenceli yolu.
LGS, YKS ve KPSS'ye hazırlanan öğrenciler için Flutter mobil uygulaması.

---

## Kurulum

### 1. Bağımlılıkları yükle
```bash
flutter pub get
```

### 2. Hive adaptörlerini üret
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Firebase kurulumu
- [Firebase Console](https://console.firebase.google.com)'da yeni proje oluştur
- Android: `google-services.json` → `android/app/` klasörüne koy
- iOS: `GoogleService-Info.plist` → `ios/Runner/` klasörüne koy
- Firebase CLI ile:
```bash
firebase login
flutterfire configure
```

### 4. Google Sign-In (Android)
`android/app/build.gradle` içinde SHA-1 parmak izi ekle:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### 5. iOS - Apple Sign In
`ios/Runner/Runner.entitlements` dosyasına ekle:
```xml
<key>com.apple.developer.applesignin</key>
<array>
  <string>Default</string>
</array>
```

### 6. Türkiye SVG Haritası
`assets/maps/turkiye.svg` dosyasını temin et.
Her ilin SVG path'inin `id` attribute'u `il-{il_kodu}` formatında olmalı.
Örnek: `<path id="il-34" d="..."/>` (İstanbul)

Ücretsiz kaynak: https://simplemaps.com/resources/svg-tr
ya da Wikipedia Türkiye haritası SVG dosyaları.

---

## Proje Yapısı

```
lib/
├── main.dart                   # Uygulama giriş noktası
├── core/
│   ├── theme/
│   │   ├── app_colors.dart     # Renk sabitleri
│   │   └── app_theme.dart      # Light + Dark tema
│   ├── router/
│   │   └── app_router.dart     # GoRouter yönlendirme
│   └── providers/
│       └── app_providers.dart  # Global Riverpod sağlayıcılar
├── features/
│   ├── onboarding/             # Karşılama ekranları
│   ├── auth/                   # Giriş, kayıt, sınav seçimi
│   ├── home/                   # Ana sayfa
│   ├── map/                    # Harita + sorular
│   ├── flashcard/              # Flash kart listesi + oynatma
│   └── profile/                # Profil, istatistik, ayarlar
├── models/                     # Veri modelleri (Hive + plain)
├── services/                   # Firebase, Hive, içerik servisleri
└── shared/                     # Ortak widget'lar, utility'ler

assets/
├── data/
│   ├── flash_cards.json        # Flash kart içerikleri
│   ├── sorular.json            # Sorular
│   └── iller.json              # 81 il verisi
└── maps/
    └── turkiye.svg             # Türkiye SVG haritası (temin edilmeli)
```

---

## İçerik Ekleme

### Flash Kart Ekle (`assets/data/flash_cards.json`)
```json
{
  "id": "fc_XXX_NNN",
  "konu": "bolgeler|daglar|gol_deniz|akarsular|tarim|iklim",
  "soru": "Soru metni",
  "cevap": "Cevap",
  "aciklama": "Açıklama",
  "gorsel": null,
  "zorluk": 1,
  "sinav": ["yks", "kpss", "lgs"]
}
```

### Soru Ekle (`assets/data/sorular.json`)
```json
{
  "id": "q_XXX_NNN",
  "soru": "Soru metni?",
  "secenekler": ["A", "B", "C", "D"],
  "dogru": 0,
  "konu": "bolgeler",
  "aciklama": "Açıklama",
  "sinav": ["yks", "kpss", "lgs"],
  "zorluk": 1
}
```

---

## Mimari Notlar

- **State Management**: Riverpod (StateNotifier + FutureProvider)
- **Navigasyon**: GoRouter (ShellRoute ile tab bar)
- **Yerel DB**: Hive (UserProgress, FlashCardState, Settings)
- **Auth**: Firebase Auth (Email + Google, Apple iOS)
- **Animasyonlar**: flutter_animate + dart:math (3D flip)
- **Streak sistemi**: `UserProgress.recordAnswer()` → günlük sayaç + streak

## İleride Eklenecekler (Mimari Hazır)
- Liderboard (Firestore collection)
- Premium abonelik (in-app purchase)
- Paylaşılabilir sonuç kartı (screenshot + share)
- Okul bazlı sıralama
