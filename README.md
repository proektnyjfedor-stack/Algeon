# Algeon

Веб-проект по математике для школьников: интерактивные задачи, темы и тренировка навыков.

## Текущий фокус

- Проект приведен к **web-only** формату.
- Основной продукт: Flutter Web приложение (`lib/` + `web/`).
- Дополнительно в репозитории есть отдельный лендинг (`web_landing/`).

## Стек

- Flutter / Dart
- Firebase Hosting + Cloud Functions
- SharedPreferences (локальный прогресс)

## Структура

```text
Algeon/
├── lib/              # Основной код Flutter-приложения
├── web/              # Web runner для Flutter
├── functions/        # Firebase Cloud Functions
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

## Важно

- В репозитории уже настроен `.gitignore` для `node_modules`, `build`, `.env` и других артефактов.
