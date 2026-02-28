# Настройка Firebase для MathPilot

## 1. Создай проект в Firebase

1. Перейди на https://console.firebase.google.com
2. Нажми "Добавить проект" (Add project)
3. Введи имя: `mathpilot`
4. Отключи Google Analytics (необязательно)
5. Нажми "Создать проект"

## 2. Добавь приложения

### Web (для тестирования в Chrome)
1. В консоли Firebase нажми на иконку `</>`
2. Введи имя: `MathPilot Web`
3. Скопируй конфиг — он понадобится в `main.dart`

### iOS
1. Нажми на иконку iOS
2. Bundle ID: `com.mathpilot.app` (или твой)
3. Скачай `GoogleService-Info.plist`
4. Положи в `ios/Runner/`

### Android
1. Нажми на иконку Android
2. Package name: `com.mathpilot.app`
3. Скачай `google-services.json`
4. Положи в `android/app/`

## 3. Включи методы авторизации

1. В Firebase Console → Authentication → Sign-in method
2. Включи:
   - **Email/Password** — просто включи
   - **Google** — включи и настрой
   - **Apple** — включи (нужен Apple Developer Account)

## 4. Настрой Google Sign-In

### Для Web:
1. Перейди в Google Cloud Console
2. APIs & Services → Credentials
3. Добавь Authorized JavaScript origins: `http://localhost`
4. Добавь Authorized redirect URIs из Firebase Console

### Для iOS:
1. Открой `ios/Runner/Info.plist`
2. Добавь URL scheme (из GoogleService-Info.plist):
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

### Для Android:
1. Получи SHA-1:
```bash
cd android
./gradlew signingReport
```
2. Добавь SHA-1 в Firebase Console → Project Settings → Android app

## 5. Настрой Apple Sign-In (iOS)

1. В Apple Developer → Identifiers → App IDs
2. Включи "Sign In with Apple"
3. В Xcode → Runner → Signing & Capabilities
4. Добавь "Sign in with Apple"

## 6. Обнови main.dart

Замени значения в `FirebaseOptions`:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: 'AIzaSy...',           // из Firebase Console
    appId: '1:123456:web:abc...',  // из Firebase Console
    messagingSenderId: '123456',    // из Firebase Console
    projectId: 'mathpilot-12345',   // из Firebase Console
    authDomain: 'mathpilot-12345.firebaseapp.com',
    storageBucket: 'mathpilot-12345.appspot.com',
  ),
);
```

## 7. Установи пакеты

```bash
cd ~/Desktop/L/math_pilot
flutter pub get
```

## 8. Запусти

```bash
flutter run -d chrome
```

---

## Быстрый старт (только Web)

Если хочешь быстро потестировать — используй FlutterFire CLI:

```bash
# Установи Firebase CLI
npm install -g firebase-tools

# Войди
firebase login

# Установи FlutterFire CLI
dart pub global activate flutterfire_cli

# Настрой проект (создаст firebase_options.dart)
flutterfire configure --project=твой-проект-id
```

Это автоматически создаст `lib/firebase_options.dart` с правильными значениями.

Потом в `main.dart`:
```dart
import 'firebase_options.dart';

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

---

## Troubleshooting

### "Google Sign-In not working on Web"
- Проверь Authorized JavaScript origins в Google Cloud Console
- Убедись что домен добавлен (localhost для разработки)

### "Apple Sign-In crashes"
- Проверь что capability добавлен в Xcode
- Проверь что Service ID создан в Apple Developer

### "Invalid API key"
- Убедись что скопировал правильный apiKey из Firebase Console
