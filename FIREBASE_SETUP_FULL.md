# 🔥 ПОЛНАЯ НАСТРОЙКА FIREBASE ДЛЯ MATHPILOT

Пошаговая инструкция с командами и скриншотами логики.

---

## 📋 ПРЕДВАРИТЕЛЬНЫЕ ТРЕБОВАНИЯ

- Google аккаунт
- Flutter SDK установлен
- Node.js и npm установлены (для Firebase CLI)
- Xcode (для iOS) / Android Studio (для Android)

---

## ЧАСТЬ 1: СОЗДАНИЕ ПРОЕКТА В FIREBASE CONSOLE

### Шаг 1: Создай проект Firebase

1. Открой https://console.firebase.google.com
2. Нажми **"Добавить проект"** (Add project)
3. Введи название: **`mathpilot`** (можно с дефисом: `math-pilot`)
4. Нажми **"Продолжить"**

5. **Google Analytics**:
   - Для разработки: **отключи** (снять галочку)
   - Для продакшена: **включи** (оставь галочку)
   - Нажми **"Создать проект"**

6. Дождись создания (20-30 секунд)
7. Нажми **"Продолжить"**

✅ Проект создан! ID проекта будет примерно таким: `mathpilot-a1b2c` (Firebase добавит рандомный суффикс)

---

## ЧАСТЬ 2: НАСТРОЙКА АВТОРИЗАЦИИ

### Шаг 2: Включи методы авторизации

1. В Firebase Console слева открой: **Authentication**
2. Нажми **"Начать"** (Get started)
3. Перейди на вкладку **"Sign-in method"**

#### 2.1 Включи Email/Password

- Нажми на **"Email/Password"**
- Переключи тумблер в **"Включено"**
- *(Опционально)* **Email link** можно оставить выключенным
- Нажми **"Сохранить"**

#### 2.2 Включи Google Sign-In

- Нажми на **"Google"**
- Переключи тумблер в **"Включено"**
- **Project support email**: выбери свой Gmail
- Нажми **"Сохранить"**

**ВАЖНО:** Запомни **Web client ID** — он понадобится!

#### 2.3 Включи Apple Sign-In (для iOS)

- Нажми на **"Apple"**
- Переключи тумблер в **"Включено"**
- Нажми **"Сохранить"**

**Требования для Apple:**
- Apple Developer Account ($99/год)
- Bundle ID: `com.mathpilot.app` (или твой)

*(Настройку Apple Developer Console опишу в Части 5)*

#### 2.4 Включи Phone Authentication

- Нажми на **"Phone"**
- Переключи тумблер в **"Включено"**
- Нажми **"Сохранить"**

**Примечание:** Phone auth требует reCAPTCHA для Web, на мобильных работает без настройки.

---

## ЧАСТЬ 3: РЕГИСТРАЦИЯ ПРИЛОЖЕНИЙ В FIREBASE

### Шаг 3.1: Добавь Web-приложение

1. На главной странице Firebase Console нажми **иконку `</>`** (Web)
2. Введи имя: **`MathPilot Web`**
3. ✅ **Включи** "Also set up Firebase Hosting" (опционально, но полезно)
4. Нажми **"Регистрировать приложение"**

5. Скопируй **Firebase Config** (будет выглядеть так):

```javascript
const firebaseConfig = {
  apiKey: "AIzaSyC1234567890abcdefghijklmnop",
  authDomain: "mathpilot-a1b2c.firebaseapp.com",
  projectId: "mathpilot-a1b2c",
  storageBucket: "mathpilot-a1b2c.firebasestorage.app",
  messagingSenderId: "123456789012",
  appId: "1:123456789012:web:abcdef1234567890"
};
```

6. Нажми **"Продолжить в консоль"**

---

### Шаг 3.2: Добавь iOS-приложение

1. На главной странице Firebase Console нажми **иконку iOS (🍎)**
2. **iOS bundle ID**: `com.mathpilot.app` (должен совпадать с Xcode!)
3. **App nickname**: `MathPilot iOS` (опционально)
4. **App Store ID**: оставь пустым (заполнишь после публикации)
5. Нажми **"Регистрировать приложение"**

6. **Скачай `GoogleService-Info.plist`**
7. Нажми **"Далее"** → **"Далее"** → **"Продолжить в консоль"**

**Установка файла (делай это позже в Xcode):**
- Открой `ios/Runner.xcworkspace` в Xcode
- Перетащи `GoogleService-Info.plist` в папку `Runner/Runner/`
- ✅ Убедись что выбрано **"Copy items if needed"**
- ✅ Убедись что Target = **Runner**

---

### Шаг 3.3: Добавь Android-приложение

1. На главной странице Firebase Console нажми **иконку Android (🤖)**
2. **Android package name**: `com.mathpilot.app`
3. **App nickname**: `MathPilot Android` (опционально)
4. **Debug signing certificate SHA-1**: получим в следующем шаге
5. Пока нажми **"Регистрировать приложение"**

6. **Скачай `google-services.json`**
7. Нажми **"Далее"** → **"Далее"** → **"Продолжить в консоль"**

**Установка файла:**
```bash
# Положи файл в:
# /Users/fedorzironkin/Desktop/L/math_pilot/android/app/google-services.json
```

**Получение SHA-1 для Google Sign-In:**
```bash
cd ~/Desktop/L/math_pilot/android
./gradlew signingReport
```

**Скопируй SHA-1** (будет примерно так: `1A:2B:3C:...`)

**Добавь SHA-1 в Firebase:**
- Firebase Console → ⚙️ Settings → Project settings
- Вкладка **"Ваши приложения"** → Android app
- Нажми **"Добавить отпечаток"**
- Вставь SHA-1 → **"Сохранить"**

---

## ЧАСТЬ 4: УСТАНОВКА FIREBASE CLI И FLUTTERFIRE

### Шаг 4: Установи Firebase Tools

#### 4.1 Установи Firebase CLI

```bash
# Через npm:
npm install -g firebase-tools

# Или через Homebrew (macOS):
brew install firebase-cli
```

Проверь установку:
```bash
firebase --version
# Должно показать версию, например: 13.0.2
```

#### 4.2 Войди в Firebase

```bash
firebase login
```

Откроется браузер → Выбери Google аккаунт → Разреши доступ → Вернись в терминал.

#### 4.3 Установи FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

Проверь установку:
```bash
flutterfire --version
```

**Если команда не найдена**, добавь в PATH:
```bash
# Для Zsh (macOS default):
echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc

# Для Bash:
echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.bashrc
source ~/.bashrc
```

---

### Шаг 5: Сгенерируй `firebase_options.dart`

```bash
cd ~/Desktop/L/math_pilot

flutterfire configure --project=mathpilot-a1b2c
```

*(Замени `mathpilot-a1b2c` на реальный ID проекта)*

**Что произойдёт:**
1. CLI покажет список твоих Firebase проектов
2. Выбери **`mathpilot-a1b2c`** (стрелками + Enter)
3. Выбери платформы: **iOS, Android, Web** (пробелом, затем Enter)
4. Автоматически создастся файл `lib/firebase_options.dart`

✅ Файл будет содержать всю конфигурацию для всех платформ!

---

## ЧАСТЬ 5: ОБНОВЛЕНИЕ КОДА ПРИЛОЖЕНИЯ

### Шаг 6: Обнови `main.dart`

**Открой:** `/Users/fedorzironkin/Desktop/L/math_pilot/lib/main.dart`

**Замени секцию Firebase init:**

```dart
// БЫЛО (старый код с TODO):
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: 'YOUR_API_KEY', // ❌ Удали это
    appId: 'YOUR_APP_ID',
    // ...
  ),
);

// СТАЛО (новый код):
import 'firebase_options.dart'; // Добавь этот import!

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

**Полный `main.dart` после изменений:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // ← Новый import

import 'theme/app_theme.dart';
import 'services/progress_service.dart';
import 'services/auth_service.dart';
import 'services/achievements_service.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  // ✅ Новый способ инициализации Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await ProgressService.init();
  await AuthService.init();
  await AchievementsService.init();
  
  runApp(const MathPilotApp());
}

// ... остальной код без изменений
```

---

## ЧАСТЬ 6: НАСТРОЙКА GOOGLE SIGN-IN

### Шаг 7.1: Web (Chrome)

**Получи Web Client ID:**
1. Firebase Console → ⚙️ Settings → Project settings
2. Вкладка **"General"**
3. Секция **"Your apps"** → Web app
4. Скопируй **Web client ID**: `123456789012-abcdefg.apps.googleusercontent.com`

**Открой:** `/Users/fedorzironkin/Desktop/L/math_pilot/web/index.html`

**Добавь в `<head>`:**
```html
<meta name="google-signin-client_id" content="123456789012-abcdefg.apps.googleusercontent.com">
```

---

### Шаг 7.2: iOS

**Получи iOS Client ID:**
1. Открой скачанный файл `GoogleService-Info.plist`
2. Найди ключ `CLIENT_ID` (будет примерно: `123456789012-xyz.apps.googleusercontent.com`)
3. Скопируй значение **в обратном порядке** (URL scheme):
   - Было: `123456789012-xyz.apps.googleusercontent.com`
   - Стало: `com.googleusercontent.apps.123456789012-xyz`

**Открой:** `/Users/fedorzironkin/Desktop/L/math_pilot/ios/Runner/Info.plist`

**Добавь перед `</dict>` в конце файла:**

```xml
<key>CFBundleURLTypes</key>
<array>
	<dict>
		<key>CFBundleTypeRole</key>
		<string>Editor</string>
		<key>CFBundleURLSchemes</key>
		<array>
			<string>com.googleusercontent.apps.123456789012-xyz</string>
		</array>
	</dict>
</array>

<key>GIDClientID</key>
<string>123456789012-xyz.apps.googleusercontent.com</string>
```

*(Замени `123456789012-xyz` на реальное значение из `GoogleService-Info.plist`!)*

---

### Шаг 7.3: Android

**Firebase уже всё настроил через SHA-1!** Ничего дополнительно делать не нужно.

Просто убедись что SHA-1 добавлен (см. Часть 3, Шаг 3.3).

---

## ЧАСТЬ 7: НАСТРОЙКА APPLE SIGN-IN (ТОЛЬКО iOS)

### Шаг 8: Apple Developer Console

**Требования:**
- Apple Developer Account ($99/год)
- Доступ к https://developer.apple.com

**8.1 Создай App ID:**

1. Открой https://developer.apple.com/account/resources/identifiers/list
2. Нажми **"+"** → **"App IDs"** → **"Continue"**
3. Выбери **"App"** → **"Continue"**
4. **Description**: `MathPilot`
5. **Bundle ID**: `Explicit` → `com.mathpilot.app`
6. ✅ Включи **"Sign In with Apple"** (в списке Capabilities)
7. Нажми **"Continue"** → **"Register"**

**8.2 Создай Service ID (для Firebase):**

1. Нажми **"+"** → **"Services IDs"** → **"Continue"**
2. **Description**: `MathPilot Sign In`
3. **Identifier**: `com.mathpilot.app.signin` (должен быть уникальным!)
4. Нажми **"Continue"** → **"Register"**

**8.3 Настрой Service ID для Firebase:**

1. Нажми на созданный Service ID
2. ✅ Включи **"Sign In with Apple"**
3. Нажми **"Configure"** рядом с чекбоксом

**8.4 Добавь домены:**

- **Domains and Subdomains**: `mathpilot-a1b2c.firebaseapp.com`  
  *(Замени на твой authDomain из Firebase Config!)*
- **Return URLs**: `https://__/auth/handler`  
  - Да, именно `__` (два подчёркивания) — это Firebase callback

5. Нажми **"Next"** → **"Done"** → **"Continue"** → **"Save"**

---

### Шаг 9: Xcode — Добавь Sign In with Apple

1. Открой `ios/Runner.xcworkspace` в Xcode
2. Выбери **Runner** (синяя иконка в левом меню)
3. Вкладка **"Signing & Capabilities"**
4. Нажми **"+ Capability"**
5. Найди и добавь **"Sign In with Apple"**

✅ Готово! Capability добавлен.

---

## ЧАСТЬ 8: ФИНАЛЬНАЯ ПРОВЕРКА

### Шаг 10: Установи зависимости

```bash
cd ~/Desktop/L/math_pilot
flutter pub get
```

---

### Шаг 11: Тестирование на разных платформах

#### 11.1 Web (Chrome)

```bash
flutter run -d chrome
```

**Проверь:**
- [ ] Email/Password авторизация работает
- [ ] Google Sign-In работает (откроется popup)
- [ ] Прогресс сохраняется локально

---

#### 11.2 iOS (Simulator или устройство)

```bash
# Список доступных устройств:
flutter devices

# Запуск на симуляторе:
flutter run -d "iPhone 15 Pro"

# Запуск на физическом устройстве (нужен Apple Developer Account):
flutter run -d <device-id>
```

**Проверь:**
- [ ] Email/Password авторизация работает
- [ ] Google Sign-In работает
- [ ] Apple Sign-In работает (только на реальном устройстве!)

**Примечание:** Apple Sign-In не работает в симуляторе — тестируй на реальном iPhone/iPad.

---

#### 11.3 Android (Emulator или устройство)

```bash
# Запуск эмулятора через Android Studio или:
flutter emulators --launch <emulator-id>

# Запуск приложения:
flutter run -d <android-device>
```

**Проверь:**
- [ ] Email/Password авторизация работает
- [ ] Google Sign-In работает
- [ ] Phone Auth работает (с SMS кодом)

---

## ЧАСТЬ 9: TROUBLESHOOTING

### ❌ Ошибка: "Google Sign-In failed" (Web)

**Причина:** Не настроены Authorized JavaScript origins.

**Решение:**
1. Google Cloud Console → APIs & Services → Credentials
2. Найди OAuth 2.0 Client ID (тип Web)
3. Добавь в **Authorized JavaScript origins**:
   - `http://localhost`
   - `http://localhost:5000`
4. Добавь в **Authorized redirect URIs**:
   - `http://localhost/__/auth/handler`
   - `https://mathpilot-a1b2c.firebaseapp.com/__/auth/handler`

---

### ❌ Ошибка: "Apple Sign-In crashes" (iOS)

**Причины:**
1. Не добавлен Capability в Xcode
2. Service ID не настроен правильно
3. Тестируешь в симуляторе (не поддерживается!)

**Решение:**
- Проверь все шаги в Части 7
- Тестируй только на реальном устройстве

---

### ❌ Ошибка: "Invalid API key" (любая платформа)

**Причина:** Неправильная конфигурация Firebase.

**Решение:**
```bash
# Удали старый файл и сгенерируй заново:
rm lib/firebase_options.dart
flutterfire configure --project=mathpilot-a1b2c
```

---

### ❌ Ошибка: "PlatformException: sign_in_failed" (Android)

**Причина:** SHA-1 не добавлен в Firebase.

**Решение:**
```bash
cd ~/Desktop/L/math_pilot/android
./gradlew signingReport
```

Скопируй SHA-1 → Firebase Console → Android app → Add fingerprint.

---

## ЧАСТЬ 10: PRODUCTION DEPLOYMENT

### Для продакшена добавь:

#### Web:
```bash
firebase init hosting
firebase deploy
```

#### iOS:
1. Xcode → Product → Archive
2. Distribute App → App Store Connect
3. Заполни App Store Connect (скриншоты, описание)
4. Submit for Review

#### Android:
```bash
flutter build appbundle
```

1. Открой Google Play Console
2. Загрузи `.aab` файл из `build/app/outputs/bundle/release/`
3. Заполни Store Listing
4. Submit for Review

---

## ✅ ЧЕКЛИСТ ГОТОВНОСТИ

- [ ] Firebase проект создан
- [ ] Authentication методы включены (Email, Google, Apple, Phone)
- [ ] Web app зарегистрировано + config скопирован
- [ ] iOS app зарегистрировано + GoogleService-Info.plist установлен
- [ ] Android app зарегистрировано + google-services.json установлен + SHA-1 добавлен
- [ ] FlutterFire CLI установлен
- [ ] `firebase_options.dart` сгенерирован
- [ ] `main.dart` обновлён (новый import + DefaultFirebaseOptions)
- [ ] Google Sign-In настроен для всех платформ
- [ ] Apple Sign-In настроен (App ID + Service ID + Xcode Capability)
- [ ] Приложение протестировано на всех платформах

---

## 🎉 ГОТОВО!

Теперь Firebase полностью настроен и готов к использованию.

Следующие шаги:
1. Добавь Firestore (для синхронизации прогресса между устройствами)
2. Настрой Cloud Functions (для серверной логики)
3. Добавь Firebase Analytics (для отслеживания юзеров)
4. Настрой Remote Config (для A/B тестов)

---

**Вопросы?** Напиши мне, и я помогу разобраться! 🚀
