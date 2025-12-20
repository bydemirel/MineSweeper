# 🎮 Minefield - Modern Flutter Minesweeper

Modern, yüksek performanslı bir Mayın Tarlası oyunu. Flutter ile geliştirilmiş, Clean Architecture prensipleriyle yapılandırılmış.

## ✨ Özellikler

- 🎯 **Dinamik Zorluk Seviyeleri**: Kolay (9x9), Orta (16x16), Zor (16x30)
- 🎨 **Modern Dark UI**: Minimal, modern ve kullanıcı dostu arayüz
- ⚡ **Yüksek Performans**: Optimize edilmiş render, gereksiz rebuild'lerden kaçınma
- 🎭 **Akıcı Animasyonlar**: Tile açılma, bayrak yerleştirme, kazanma/kaybetme animasyonları
- 📱 **Haptic Feedback**: Dokunsal geri bildirim ile gelişmiş kullanıcı deneyimi
- 🔒 **Güvenli İlk Tıklama**: İlk tıklamada asla mayına basılmaz
- 🚩 **Bayrak Sistemi**: Uzun basarak mayınları işaretle
- 🎊 **Kazanma Animasyonu**: Hafif confetti animasyonu
- 💥 **Patlama Animasyonu**: Mayına basıldığında görsel geri bildirim

## 🏗️ Mimari

Proje **Clean Architecture** prensipleriyle yapılandırılmıştır:

```
lib/
├── domain/           # İş mantığı katmanı
│   ├── entities/     # Domain modelleri
│   └── repositories/ # Repository arayüzleri
├── data/            # Veri katmanı
│   └── repositories/ # Repository implementasyonları
└── presentation/    # UI katmanı
    ├── providers/   # Riverpod state management
    ├── screens/     # Ekranlar
    └── widgets/     # Yeniden kullanılabilir widget'lar
```

### Katmanlar

1. **Domain Layer**: İş mantığı, entities ve repository arayüzleri
2. **Data Layer**: Repository implementasyonları ve veri işleme
3. **Presentation Layer**: UI, state management (Riverpod), widget'lar

## 🚀 Kurulum

1. Flutter SDK'yı yükleyin (3.0.0+)
2. Bağımlılıkları yükleyin:
```bash
flutter pub get
```

3. Uygulamayı çalıştırın:
```bash
flutter run
```

## 🎮 Oynanış

- **Kısa Tıklama**: Kareyi aç
- **Uzun Basma**: Bayrak yerleştir/kaldır
- **İlk Tıklama**: Güvenli - asla mayına basılmaz
- **Boş Kareler**: Otomatik olarak açılır (recursive reveal)
- **Kazanma**: Tüm mayınsız kareleri aç
- **Kaybetme**: Bir mayına bas

## ⚡ Performans Optimizasyonları

1. **RepaintBoundary**: Game board için ayrı repaint boundary
2. **Const Widgets**: Mümkün olduğunca const widget'lar kullanıldı
3. **Selective Rebuilds**: Riverpod ile sadece gerekli widget'lar rebuild edilir
4. **Implicit Animations**: Ağır animasyonlar yerine Flutter native animasyonlar
5. **CustomPainter**: Hafif confetti ve patlama animasyonları
6. **GridView.builder**: Büyük grid'ler için optimize edilmiş rendering

## 🛠️ Teknolojiler

- **Flutter**: 3.0.0+
- **Riverpod**: State management
- **Equatable**: Value equality
- **Flutter Haptic Feedback**: Dokunsal geri bildirim

## 📝 Kod Kalitesi

- ✅ Null safety enabled
- ✅ Clean Architecture
- ✅ Well-commented code
- ✅ Scalable structure
- ✅ Performance-oriented

## 🔮 Gelecek Özellikler

- [ ] Tema sistemi (light/dark mode toggle)
- [ ] Liderlik tablosu
- [ ] İstatistikler
- [ ] Özel zorluk seviyeleri
- [ ] Ses efektleri

## 📄 Lisans

Bu proje eğitim amaçlı geliştirilmiştir.

