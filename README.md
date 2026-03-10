# Algeon — математика с пониманием

> Мобильное приложение-тренажёр по математике для школьников 1–4 классов.
> Задачи, теория, AI-подсказки, достижения, подготовка к ОГЭ/ЕГЭ.

**Версия:** 1.0.0  
**Дата:** 10 марта 2026  
**Стек:** Flutter + Firebase + OpenAI (GPT) · Планируется: FastAPI + Claude + RAG  
**Платформы:** Android, iOS (Web — частично)

---

## Содержание

- [Структура проекта](#структура-проекта)
- [Что нужно для сборки](#что-нужно-для-сборки)
- [Запуск](#запуск)
- [Архитектура](#архитектура)
- [AI-интеграция](#ai-интеграция)
- [Данные и задачи](#данные-и-задачи)
- [Статус разработки](#статус-разработки)

---

## Структура проекта

```
git/
├── lib/                              ← ОСНОВНОЙ КОД ПРИЛОЖЕНИЯ
│   ├── main.dart                     ← Точка входа (Provider, GoRouter, тема)
│   ├── firebase_options.dart         ← Firebase конфиг (Android/iOS)
│   │
│   ├── models/                       ← Модели данных
│   │   ├── task.dart                 ← Задача (multipleChoice / textInput)
│   │   └── user.dart                 ← Пользователь
│   │
│   ├── data/                         ← Статические данные
│   │   ├── tasks_data.dart           ← Основной банк: ~460 задач, 1–4 класс
│   │   ├── curriculum_tasks.dart     ← Доп. задачи по школьной программе
│   │   ├── topic_theory.dart         ← Теория по темам
│   │   └── oge_ege_data.dart         ← Данные ОГЭ/ЕГЭ
│   │
│   ├── screens/                      ← Экраны (18 файлов)
│   │   ├── splash_screen.dart        ← Заставка
│   │   ├── onboarding_welcome_screen ← Онбординг
│   │   ├── auth/login/register       ← Авторизация (Firebase Auth)
│   │   ├── main_screen.dart          ← Главный экран с табами
│   │   ├── home_tab.dart             ← Домашняя вкладка
│   │   ├── task_screen.dart          ← Решение задач
│   │   ├── topics_screen.dart        ← Выбор темы
│   │   ├── topic_intro_screen.dart   ← Введение в тему
│   │   ├── practice_tab.dart         ← Практика
│   │   ├── exams_tab.dart            ← ОГЭ/ЕГЭ
│   │   ├── achievements_*.dart       ← Достижения
│   │   ├── profile_tab.dart          ← Профиль
│   │   └── summary_screen.dart       ← Итоги занятия
│   │
│   ├── services/                     ← Бизнес-логика
│   │   ├── ai_service.dart           ← AI: генерация задач, подсказки, анализ ошибок (OpenAI GPT)
│   │   ├── auth_service.dart         ← Firebase Auth (email, Google, Apple)
│   │   ├── progress_service.dart     ← Прогресс ученика (SharedPreferences)
│   │   ├── achievements_service.dart ← Система достижений (SharedPreferences)
│   │   └── sound_service.dart        ← Звуковые эффекты
│   │
│   ├── theme/                        ← Оформление
│   │   ├── app_theme.dart            ← Светлая и тёмная тема
│   │   └── theme_provider.dart       ← Переключение тем
│   │
│   ├── widgets/                      ← Переиспользуемые компоненты
│   │   ├── math_text.dart            ← Рендеринг LaTeX-формул
│   │   ├── math_keyboard.dart        ← Математическая клавиатура
│   │   ├── app_logo.dart             ← Логотип
│   │   └── avatar*.dart              ← Аватар пользователя
│   │
│   └── router/app_router.dart        ← GoRouter навигация
│
├── functions/                        ← FIREBASE CLOUD FUNCTIONS
│   └── index.js                      ← Прокси к OpenAI API (ключ на сервере)
│
├── ai-backend/                       ← ЗАГОТОВКА Claude-бэкенда (пока пусто)
│   └── .env.example                  ← Шаблон: ANTHROPIC_API_KEY=
│
├── assets/                           ← Ресурсы
│   ├── animations/                   ← Lottie/анимации
│   └── sounds/                       ← Звуки
│
├── web_landing/                      ← Лендинг (HTML/CSS/JS)
├── .github/workflows/                ← CI/CD
│   ├── deploy-web.yml                ← Деплой веб-версии
│   └── test.yml                      ← Тесты
│
├── android/ ios/ web/ macos/ linux/ windows/  ← Платформенные файлы
├── math_pilot/                       ← Пустая (бывший submodule)
├── pubspec.yaml                      ← Зависимости Flutter
├── firebase.json                     ← Конфигурация Firebase Hosting
├── .firebaserc                       ← Firebase проект: algeon-66295
└── *.md                              ← Документация (Firebase, CI/CD, UX, Assets)
```

---

## Что нужно для сборки

### Минимальные требования

| Инструмент | Версия | Зачем |
|-----------|--------|-------|
| Flutter SDK | ≥ 3.0.0, < 4.0.0 | Фреймворк приложения |
| Dart SDK | идёт с Flutter | Язык программирования |
| Git | любая | Контроль версий |
| Android Studio | последняя | Android SDK + эмулятор |
| Xcode | последняя (только macOS) | Сборка под iOS |

### Зависимости (pubspec.yaml)

| Пакет | Назначение |
|-------|-----------|
| `shared_preferences` | Локальное хранение прогресса |
| `google_fonts` | Шрифты |
| `firebase_core` + `firebase_auth` | Авторизация (Firebase) |
| `go_router` | Навигация между экранами |
| `provider` | State management |
| `http` | HTTP-запросы к AI API |
| `flutter_math_fork` | Рендеринг LaTeX-формул (дроби, степени, корни) |
| `image_picker` | Выбор фото для аватара |

### Firebase

Приложение использует Firebase для авторизации и AI-прокси.

1. **Firebase проект:** `algeon-66295` (см. `.firebaserc`)
2. **Android:** нужен файл `android/app/google-services.json` (из Firebase Console)
3. **iOS:** нужен файл `ios/Runner/GoogleService-Info.plist` (из Firebase Console)
4. **Cloud Functions:** OpenAI ключ задаётся через:
   ```bash
   firebase functions:config:set openai.key="sk-proj-..."
   ```

> ⚠️ **Известная проблема:** в `firebase_options.dart` указан проект `mathpilot-app`,
> а в `.firebaserc` — `algeon-66295`. Нужно привести к единому проекту.

> ⚠️ **Web:** Firebase Web конфигурация отсутствует — `firebase_options.dart`
> выбрасывает `UnsupportedError` для Web-платформы.

---

## Запуск

```bash
# 1. Установи зависимости
flutter pub get

# 2. Запусти на подключённом устройстве / эмуляторе
flutter run

# 3. Только Android
flutter run -d android

# 4. Только iOS (macOS)
flutter run -d ios

# 5. Web (ограниченная поддержка)
flutter run -d chrome
```

---

## Архитектура

```
┌─────────────────┐     HTTP/JSON     ┌──────────────────────┐
│                 │ ──────────────────▶│  Firebase Function   │
│  Flutter App    │                    │  (functions/index.js)│
│  (lib/)         │◀──────────────────│                      │
│                 │     Ответ GPT     │  Прокси к OpenAI     │
└────────┬────────┘                    └──────────┬───────────┘
         │                                        │
         │ SharedPreferences                      │ HTTPS
         │ (локальное хранение)                   ▼
         │                              ┌──────────────────┐
         │                              │   OpenAI API     │
         │                              │   (gpt-4o-mini)  │
         │                              └──────────────────┘
         │
         │     Firebase Auth
         ▼
┌─────────────────┐
│  Firebase       │
│  (Auth only)    │
└─────────────────┘
```

**Ключевые решения:**
- **Прогресс хранится локально** (SharedPreferences), не в облаке
- **AI-ключ на сервере** — Flutter не хранит OpenAI ключ, запросы идут через Firebase Function
- **Навигация** — GoRouter (декларативная, deep linking)
- **State management** — Provider (для темы)

---

## AI-интеграция

### Текущее состояние (OpenAI GPT)

Файл: `lib/services/ai_service.dart`

| Функция | Описание | Статус |
|---------|----------|--------|
| `generateTasks()` | Генерация новых задач по теме и классу | ✅ Работает |
| `generateHint()` | Подсказка к задаче (без раскрытия ответа) | ✅ Работает |
| `analyzeErrors()` | Анализ ошибок + рекомендации | ✅ Работает |

**Как работает:**
1. Flutter → POST JSON → Firebase Function (`aiProxy`)
2. Firebase Function → добавляет API-ключ → OpenAI API (`gpt-4o-mini`)
3. OpenAI → ответ → Firebase Function → Flutter

### Планируемая миграция (Claude + RAG)

Папка `ai-backend/` — заготовка для отдельного Python-бэкенда.
Техническая спецификация: `Docs/AI_training_TS_v4_mac.md`

| Компонент | Текущее | Планируемое |
|-----------|---------|-------------|
| LLM | OpenAI GPT-4o-mini | Claude Sonnet 4 |
| Прокси | Firebase Function (JS) | FastAPI (Python, async) |
| Поиск по учебникам | ❌ Нет | RAG: ChromaDB + embeddings |
| Стриминг ответов | ❌ Нет | SSE (Server-Sent Events) |
| История чата | ❌ Нет | Redis с TTL |
| Экран чата с репетитором | ❌ Нет | Новый экран в Flutter |
| Rate limiting | ❌ Нет | slowapi (по IP/user) |
| Модерация контента | ❌ Нет | Perspective API |

---

## Данные и задачи

### Банк задач

| Файл | Содержание | Объём |
|------|-----------|-------|
| `data/tasks_data.dart` | Основные задачи 1–4 класс, 5–6 тем на класс | ~460 задач |
| `data/curriculum_tasks.dart` | Доп. темы по школьной программе 1–11 класс | ~650 строк |
| `data/topic_theory.dart` | Теоретический материал | по темам |
| `data/oge_ege_data.dart` | Данные ОГЭ/ЕГЭ | структура экзаменов |

### Модель задачи (`models/task.dart`)

```dart
Task(
  id: 'g1_count_1',         // Уникальный ID
  grade: 1,                  // Класс (1–11)
  topic: 'Счёт до 10',       // Тема
  question: '2 + 3 = ?',     // Вопрос
  type: TaskType.multipleChoice,  // Тип: выбор или ввод
  options: ['4', '5', '6', '7'], // Варианты (для multipleChoice)
  answer: '5',               // Правильный ответ
  hint: 'Посчитай на пальцах', // Подсказка (опционально)
  explanationSteps: [...],    // Пошаговое объяснение (опционально)
)
```

---

## Статус разработки

### Что готово ✅

- Полный UI: 18 экранов (онбординг, авторизация, задачи, профиль, достижения)
- Банк задач: ~460 задач для 1–4 классов + доп. задачи по программе
- Firebase Auth: email/password, Google, Apple Sign-In
- AI через OpenAI GPT: генерация задач, подсказки, анализ ошибок
- Система прогресса: streak, статистика, достижения
- Тёмная/светлая тема
- LaTeX-рендеринг математических формул
- Лендинг (`web_landing/`)
- CI/CD: GitHub Actions (тесты, деплой Web)

### Что в процессе 🔧

- Миграция AI с OpenAI → Claude + RAG (спецификация готова, код — нет)
- Папка `ai-backend/` создана, но пуста (только `.env.example`)

### Известные проблемы ⚠️

1. **Firebase не инициализируется** — в `main.dart` нет `Firebase.initializeApp()`.
   Auth-сервис использует `FirebaseAuth.instance`, но без инициализации приложение
   упадёт при попытке авторизации.
2. **Конфликт Firebase-проектов** — `.firebaserc` ссылается на `algeon-66295`,
   а `firebase_options.dart` — на `mathpilot-app`.
3. **Web не поддерживается** — `firebase_options.dart` выбрасывает ошибку для Web,
   хотя есть CI/CD деплой и лендинг.
4. **Прогресс только локальный** — SharedPreferences не синхронизируется между
   устройствами. При переустановке приложения данные теряются.

---

## Документация

| Файл | Описание |
|------|----------|
| `FIREBASE_SETUP.md` | Настройка Firebase |
| `FIREBASE_SETUP_COMPLETE.md` | Полная инструкция Firebase |
| `CI_CD_SETUP.md` | Настройка CI/CD |
| `ASSETS_GUIDE.md` | Работа с ресурсами |
| `SOUNDS_AND_ANIMATIONS.md` | Звуки и анимации |
| `UX_IMPROVEMENTS.md` | Улучшения UX |
| `UX_OPTIMIZATION.md` | Оптимизация UX |
| `Docs/AI_training_TS_v4_mac.md` | Техспецификация AI-бэкенда (v4) |
| `Docs/phase2-updated-v3.1.md` | Фаза 2: умный поиск + защита |

## Связанные репозитории

| Репозиторий | Назначение | Статус |
|------------|-----------|--------|
| `Algeon` (этот) | Flutter-приложение | Активный |
| `algeon-ai-backend` | Python/FastAPI AI-бэкенд | Не начат |

---

*Последнее обновление: 10 марта 2026*
