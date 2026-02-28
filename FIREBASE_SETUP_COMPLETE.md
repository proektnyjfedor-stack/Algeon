# 🔥 Firebase Setup — Полная инструкция для MathPilot

## Шаг 1: Создание проекта Firebase (5 минут)

### 1.1 Создай проект
1. Открой [Firebase Console](https://console.firebase.google.com)
2. Нажми **"Add project"** (Добавить проект)
3. Введи название: `mathpilot-production`
4. **Отключи Google Analytics** (можно включить позже)
5. Нажми **"Create project"**
6. Дождись завершения создания (30-60 секунд)

---

## Шаг 2: Настройка для Web (Chrome тестирование)

### 2.1 Добавь Web App
1. В Firebase Console нажми на иконку **`</>`** (Web)
2. Введи nickname: `MathPilot Web`
3. **Не ставь** галочку "Firebase Hosting"
4. Нажми **"Register app"**

### 2.2 Скопируй конфигурацию
Увидишь код вида:
```javascript
const firebaseConfig = {
  apiKey: "AIzaSyA...",
  authDomain: "mathpilot-xxxxx.firebaseapp.com",
  projectId: "mathpilot-xxxxx",
  storageBucket: "mathpilot-xxxxx.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcdef"
};
```

### 2.3 Обнови main.dart
Открой `lib/main.dart` и замени строки 35-40:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: 'AIzaSyA...',                              // ⬅️ ТВОЙ apiKey
    appId: '1:123456789:web:abcdef',                   // ⬅️ ТВОЙ appId
    messagingSenderId: '123456789',                    // ⬅️ ТВОЙ messagingSenderId
    projectId: 'mathpilot-xxxxx',                      // ⬅️ ТВОЙ projectId
    authDomain: 'mathpilot-xxxxx.firebaseapp.com',     // ⬅️ ТВОЙ authDomain
    storageBucket: 'mathpilot-xxxxx.appspot.com',      // ⬅️ ТВОЙ storageBucket
  ),
);
```

---

## Шаг 3: Включи методы авторизации (10 минут)

### 3.1 Email/Password
1. Firebase Console → **Authentication**
2. Нажми **"Get started"**
3. Вкладка **"Sign-in method"**
4. Нажми на **"Email/Password"**
5. Включи переключатель **"Enable"**
6. Нажми **"Save"**

✅ **Готово!** Самый простой метод настроен.

---

### 3.2 Google Sign-In (сложнее)

#### 3.2.1 Включи в Firebase
1. Sign-in method → **"Google"**
2. Включи переключатель
3. Выбери **Support email** (твой email)
4. Нажми **"Save"**

#### 3.2.2 Настрой для Web
1. Перейди в [Google Cloud Console](https://console.cloud.google.com)
2. Выбери проект `mathpilot-xxxxx`
3. **APIs & Services → Credentials**
4. Найди **"Web client"** (создан автоматически)
5. Нажми на название, чтобы редактировать
6. В секции **"Authorized JavaScript origins"** добавь:
   ```
   http://localhost
   http://localhost:8080
   ```
7. В секции **"Authorized redirect URIs"** добавь:
   ```
   http://localhost
   https://mathpilot-xxxxx.firebaseapp.com/__/auth/handler
   ```
   (замени `mathpilot-xxxxx` на свой ID)
8. Нажми **"Save"**

#### 3.2.3 Настрой для iOS (если планируешь)
1. Открой `ios/Runner/GoogleService-Info.plist`
2. Найди значение `REVERSED_CLIENT_ID` (например `com.googleusercontent.apps.123...`)
3. Открой `ios/Runner/Info.plist`
4. Добавь перед `</dict>`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
    </array>
  </dict>
</array>
```
(замени `YOUR_CLIENT_ID` на значение из REVERSED_CLIENT_ID)

#### 3.2.4 Настрой для Android (если планируешь)
1. Получи SHA-1 отпечаток:
```bash
cd ~/Desktop/L/math_pilot/android
./gradlew signingReport
```
2. Скопируй SHA-1 из вывода (строка `SHA1: A1:B2:C3...`)
3. Firebase Console → **Project Settings** → вкладка **"Your apps"**
4. Найди Android app → нажми **"Add fingerprint"**
5. Вставь SHA-1 и нажми **"Save"**

---

### 3.3 Apple Sign-In (только для iOS, очень сложно)

**⚠️ Требуется Apple Developer Account ($99/год)**

#### 3.3.1 Включи в Firebase
1. Sign-in method → **"Apple"**
2. Включи переключатель
3. Нажми **"Save"**

#### 3.3.2 Настрой в Apple Developer
1. Открой [Apple Developer → Identifiers](https://developer.apple.com/account/resources/identifiers)
2. Выбери свой **App ID**
3. Включи галочку **"Sign In with Apple"**
4. Нажми **"Save"**

#### 3.3.3 Настрой в Xcode
1. Открой `ios/Runner.xcworkspace` в Xcode
2. Выбери **Runner** в левой панели
3. Вкладка **"Signing & Capabilities"**
4. Нажми **"+ Capability"**
5. Добавь **"Sign in with Apple"**

---

### 3.4 Phone Authentication (SMS) — ОПЦИОНАЛЬНО

**⚠️ Требуется платёжная информация в Google Cloud**

1. Sign-in method → **"Phone"**
2. Включи переключатель
3. Firebase попросит включить **Identity Platform**
4. Настрой платёжный профиль в Google Cloud
5. Получишь лимит: 10,000 бесплатных верификаций/месяц

---

## Шаг 4: Тестирование (5 минут)

### 4.1 Запусти приложение
```bash
cd ~/Desktop/L/math_pilot
flutter pub get
flutter run -d chrome
```

### 4.2 Проверь авторизацию
1. Приложение откроется в Chrome
2. Попробуй зарегистрироваться через Email
3. Проверь Firebase Console → **Authentication → Users**
4. Должен появиться новый пользователь

### 4.3 Если ошибки
- **"Firebase not initialized"**: проверь, что скопировал правильные ключи в `main.dart`
- **"Invalid API key"**: проверь `apiKey` в `main.dart`
- **Google Sign-In не работает**: проверь Authorized origins в Google Cloud Console

---

## Шаг 5: Продакшн настройки (ВАЖНО!)

### 5.1 Безопасность API Key
**🚨 ВАЖНО**: Твой API Key в `main.dart` виден всем!

Для Web это нормально, но добавь ограничения:
1. Google Cloud Console → **APIs & Services → Credentials**
2. Найди свой API Key
3. Нажми **"Edit"**
4. **Application restrictions** → выбери **"HTTP referrers"**
5. Добавь:
   ```
   localhost/*
   твой-домен.com/*
   ```
6. Нажми **"Save"**

### 5.2 Firebase Security Rules
1. Firebase Console → **Firestore Database** (если используешь)
2. Вкладка **"Rules"**
3. Напиши правила (пример):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 🎯 Быстрая настройка через CLI (альтернатива)

Если не хочешь всё делать вручную:

```bash
# Установи Firebase CLI
npm install -g firebase-tools

# Войди
firebase login

# Установи FlutterFire CLI
dart pub global activate flutterfire_cli

# Автоматическая настройка
cd ~/Desktop/L/math_pilot
flutterfire configure --project=mathpilot-xxxxx
```

Это создаст файл `lib/firebase_options.dart` автоматически.

Потом в `main.dart`:
```dart
import 'firebase_options.dart';

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

---

## 📊 Что дальше?

После настройки Firebase ты можешь:

### ✅ Уже работает:
- Email/Password авторизация
- Локальное хранение прогресса
- Все 200 задач

### 🔜 Можно добавить:
- **Firestore Database** — синхронизация прогресса между устройствами
- **Cloud Functions** — серверная логика (например, проверка ответов)
- **Firebase Analytics** — отслеживание поведения пользователей
- **Cloud Messaging** — push-уведомления
- **Remote Config** — изменение контента без обновления приложения
- **Crashlytics** — отслеживание ошибок

---

## 🆘 Troubleshooting

### Google Sign-In не работает в Web
```
Error: "Invalid origin"
```
**Решение**: Добавь `http://localhost` в Authorized JavaScript origins

### Apple Sign-In не работает
```
Error: "Invalid configuration"
```
**Решение**: Проверь, что добавил Capability в Xcode

### Firebase не инициализируется
```
Error: "[core/no-app] No Firebase App..."
```
**Решение**: Убедись, что `Firebase.initializeApp()` вызывается до `runApp()`

### Ошибка компиляции iOS
```
Error: No such module 'Firebase'
```
**Решение**:
```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
```

---

## 📞 Контакты

Если что-то не получается:
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev)
- [Firebase Support](https://firebase.google.com/support)

---

**🎉 Готово!** После выполнения всех шагов у тебя будет полностью настроенный Firebase с авторизацией.
