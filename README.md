# Algeon

Веб-проект по математике для школьников: интерактивные задачи, темы, подсказки AI и тренировка навыков.

## Текущий фокус

- Проект приведен к **web-only** формату.
- Основной продукт: Flutter Web приложение (`lib/` + `web/`).
- AI-запросы идут через Firebase Cloud Function-прокси (`functions/index.js`).
- Дополнительно в репозитории есть отдельный лендинг (`web_landing/`).

## Стек

- Flutter / Dart
- Firebase Hosting + Cloud Functions
- OpenAI API (через серверный прокси)
- SharedPreferences (локальный прогресс)

## Структура

```text
Algeon/
├── lib/              # Основной код Flutter-приложения
├── web/              # Web runner для Flutter
├── functions/        # Firebase Function aiProxy
├── web_landing/      # Отдельный HTML/CSS/JS лендинг
├── assets/           # Ресурсы (sounds, animations)
├── test/             # Тесты
├── firebase.json     # Конфиг Firebase Hosting/Functions
├── pubspec.yaml      # Flutter зависимости
└── README.md
```

## Локальный запуск

```bash
flutter pub get
flutter run -d chrome
```

## Сборка веба

```bash
flutter build web --release
```

## Деплой

Hosting настроен через `firebase.json` (public: `build/web`).

Базовый поток:

```bash
firebase deploy --only hosting
```

Если нужно деплоить функцию прокси:

```bash
firebase deploy --only functions
```

## AI-поток

1. Клиент вызывает `lib/services/ai_service.dart`.
2. Запрос идет в `aiProxy` (`functions/index.js`).
3. Функция добавляет API-ключ на сервере и отправляет запрос в OpenAI.
4. Ответ возвращается клиенту.

## Важно

- Не храните API-ключи в клиентском коде.
- Для функций используйте серверную конфигурацию Firebase (`functions:config:set`).
- В репозитории уже настроен `.gitignore` для `node_modules`, `build`, `.env` и других артефактов.
