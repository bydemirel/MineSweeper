# Mimari Kararlar ve Performans Optimizasyonları

## Mimari Kararlar

### Clean Architecture

Proje üç ana katmandan oluşur:

#### 1. Domain Layer
- **Entities**: `TileState`, `GameState`, `GameDifficulty`
- **Repositories**: `GameRepository` (interface)
- İş mantığı burada bulunur, platform bağımsızdır

#### 2. Data Layer
- **Repository Implementations**: `GameRepositoryImpl`
- Domain katmanındaki arayüzleri implement eder
- Veri işleme ve algoritmalar burada

#### 3. Presentation Layer
- **Providers**: Riverpod state management
- **Screens**: Ana ekranlar
- **Widgets**: Yeniden kullanılabilir UI bileşenleri

### State Management: Riverpod

Riverpod seçilme nedenleri:
- ✅ Yüksek performans (selective rebuilds)
- ✅ Type-safe
- ✅ Test edilebilir
- ✅ Dependency injection built-in
- ✅ Compile-time safety

## Performans Optimizasyonları

### 1. Widget Optimizasyonu

```dart
// RepaintBoundary kullanımı
RepaintBoundary(
  child: GameBoard(...)
)
```

Game board ayrı bir repaint boundary içinde, böylece sadece board değiştiğinde repaint edilir.

### 2. Const Widgets

Mümkün olduğunca const widget'lar kullanıldı:
- Statik text'ler
- Icon'lar
- Sabit değerler

### 3. Selective Rebuilds

Riverpod'un `watch` ve `read` mekanizması sayesinde:
- Sadece değişen state'e bağlı widget'lar rebuild edilir
- Game board sadece board state değiştiğinde rebuild edilir
- Status bar sadece ilgili değerler değiştiğinde güncellenir

### 4. Animasyon Optimizasyonu

**Implicit Animations**: Ağır Lottie dosyaları yerine Flutter native animasyonlar:
- `AnimatedContainer`
- `AnimatedScale`
- `AnimatedOpacity`
- `AnimationController` ile custom animasyonlar

**CustomPainter**: Hafif confetti ve patlama animasyonları:
- CPU-friendly
- Minimal memory footprint
- Smooth 60fps

### 5. Game Logic Optimizasyonu

**Recursive Reveal**: Boş kareler için optimize edilmiş recursive algoritma:
- Sadece gerekli kareler açılır
- Stack overflow riski minimize edildi
- Boundary checks ile güvenli

**Mine Generation**: 
- İlk tıklamada güvenli alan garantisi
- Random seed ile deterministik test edilebilirlik
- Efficient position calculation

### 6. Memory Management

- **Equatable**: Value equality ile gereksiz rebuild'lerden kaçınma
- **Immutable State**: State değişiklikleri copyWith ile
- **Dispose**: Animation controller'lar düzgün dispose edilir

## Widget Yapısı

### TileWidget
- Her tile için ayrı animation controller
- State-based animations (reveal, flag)
- Haptic feedback entegrasyonu
- Press state management

### GameBoard
- Responsive tile sizing
- Screen size'a göre otomatik ayarlama
- RepaintBoundary ile izolasyon

### StatusBar
- Minimal rebuilds
- Formatted time display
- Icon-based status indication

## Animasyon Detayları

### Tile Reveal Animation
1. Scale down (1.0 → 0.0)
2. Opacity fade (1.0 → 0.0)
3. Duration: 200ms
4. Curve: easeOut

### Flag Animation
1. Scale up (1.0 → 1.3)
2. Scale down (1.3 → 1.0)
3. Duration: 150ms
4. Curve: elasticOut

### Win Animation
- 50 particle
- Custom painter ile rendering
- Fade out effect
- Random colors ve positions

### Explosion Animation
- Scale: 0.0 → 2.0
- Opacity: 1.0 → 0.0
- Multi-layer (glow, ring, core)
- Particle effects

## Test Edilebilirlik

Clean Architecture sayesinde:
- Domain logic unit test edilebilir
- Repository mock'lanabilir
- UI widget'ları izole test edilebilir

## Ölçeklenebilirlik

Yapı gelecekteki özellikler için hazır:
- **Themes**: Theme provider eklenebilir
- **Leaderboard**: Data layer'a persistence eklenebilir
- **Statistics**: Domain'e yeni entity'ler eklenebilir
- **Custom Difficulty**: GameDifficulty enum genişletilebilir

## Güvenlik

- Null safety: Tüm kod null-safe
- Type safety: Strong typing
- Boundary checks: Array bounds kontrolü
- Safe first click: İlk tıklamada mayın garantisi yok

