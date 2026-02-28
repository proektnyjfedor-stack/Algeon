# 🎵 Звуки и анимации для MathPilot

## Структура файлов

```
assets/
├── sounds/
│   ├── correct.mp3         # Правильный ответ
│   ├── wrong.mp3           # Неправильный ответ
│   ├── complete.mp3        # Завершение темы
│   ├── achievement.mp3     # Получение достижения
│   └── click.mp3           # Клик по кнопке
│
└── animations/
    ├── confetti.json       # Конфетти (Lottie)
    ├── success.json        # Галочка успеха
    ├── error.json          # Крестик ошибки
    └── loading.json        # Загрузка
```

## Где взять ресурсы

### 🎵 Звуки (бесплатные источники):

1. **Freesound.org**
   - Correct: https://freesound.org/people/LittleRobotSoundFactory/sounds/270303/
   - Wrong: https://freesound.org/people/InspectorJ/sounds/403012/
   - Complete: https://freesound.org/people/EVRetro/sounds/495005/
   
2. **Mixkit.co/free-sound-effects**
   - UI sounds коллекция

3. **Zapsplat.com** (требует регистрацию)
   - Massive library

### 🎨 Анимации Lottie:

1. **LottieFiles.com**
   - Confetti: https://lottiefiles.com/animations/confetti-animation
   - Success: https://lottiefiles.com/animations/success-checkmark
   - Error: https://lottiefiles.com/animations/error-cross
   - Loading: https://lottiefiles.com/animations/loading-spinner

2. **Создай свои**:
   - After Effects + Bodymovin plugin
   - https://airbnb.io/lottie/

## Быстрая установка (скрипт)

Запусти скрипт для автоматической загрузки:

```bash
cd ~/Desktop/L/math_pilot
./download_assets.sh
```

## Ручная установка

### Шаг 1: Создай папки

```bash
cd ~/Desktop/L/math_pilot
mkdir -p assets/sounds
mkdir -p assets/animations
```

### Шаг 2: Скачай звуки

Используй cURL или wget:

```bash
# Correct sound (пример)
curl -L "https://freesound.org/data/previews/270/270303_3635985-lq.mp3" \
     -o assets/sounds/correct.mp3

# Wrong sound
curl -L "https://freesound.org/data/previews/403/403012_7170046-lq.mp3" \
     -o assets/sounds/wrong.mp3
```

### Шаг 3: Скачай анимации

```bash
# Confetti animation
curl -L "https://assets10.lottiefiles.com/packages/lf20_abc123xyz.json" \
     -o assets/animations/confetti.json
```

## Альтернатива: Использовать placeholder

Если не хочешь скачивать сейчас, используй встроенные звуки Flutter:

```dart
// В sound_service.dart
import 'package:flutter/services.dart';

Future<void> playCorrect() async {
  // Используй системный звук
  await SystemSound.play(SystemSoundType.click);
}
```

## Интеграция в код

### SoundService уже готов!

Файл `lib/services/sound_service.dart` уже настроен:

```dart
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final _player = AudioPlayer();
  
  static Future<void> playCorrect() async {
    await _player.play(AssetSource('sounds/correct.mp3'));
  }
  
  static Future<void> playWrong() async {
    await _player.play(AssetSource('sounds/wrong.mp3'));
  }
}
```

### Используй в TaskScreen:

```dart
// Когда пользователь отвечает правильно
if (isCorrect) {
  await SoundService.playCorrect();
  await VibrationService.success();
}
```

## Настройки громкости

Добавь в настройки приложения:

```dart
class Settings {
  static bool soundEnabled = true;
  static double volume = 0.8; // 0.0 - 1.0
  
  static Future<void> toggleSound() async {
    soundEnabled = !soundEnabled;
    await SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool('sound_enabled', soundEnabled));
  }
}
```

## Тестирование

```bash
# Запусти на реальном устройстве (эмуляторы могут не поддерживать звук)
flutter run -d <device_id>

# Проверь звуки
flutter test test/sound_service_test.dart
```

## Лицензии

**ВАЖНО**: Убедись что звуки имеют правильную лицензию:
- ✅ CC0 (Public Domain)
- ✅ CC BY (Attribution)
- ❌ Proprietary (требует покупки)

Добавь атрибуцию в `CREDITS.md`:

```markdown
# Sound Credits

- correct.mp3: [Author Name] - Freesound.org (CC0)
- wrong.mp3: [Author Name] - Freesound.org (CC BY 3.0)
```

## Генерация собственных звуков

### Онлайн генераторы:

1. **Bfxr.net** - 8-bit звуки
2. **Chiptone.app** - Chiptune генератор
3. **SFXR** - Sound effects generator

### AI генераторы:

1. **ElevenLabs** (Text-to-Sound)
2. **Soundraw.io** (AI music)

---

**Создано для MathPilot © 2025**
