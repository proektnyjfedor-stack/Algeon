#!/bin/bash

# 🔥 Firebase Setup Automation Script
# Для MathPilot (Algeon)

set -e  # Exit on error

echo "🚀 MathPilot Firebase Setup"
echo "================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    error "Не найден pubspec.yaml. Запусти скрипт из корня проекта math_pilot"
fi

PROJECT_NAME=$(grep "^name:" pubspec.yaml | awk '{print $2}')
if [ "$PROJECT_NAME" != "math_pilot" ]; then
    warning "Project name: $PROJECT_NAME (ожидалось: math_pilot)"
fi

echo ""
info "Проверка зависимостей..."

# Check Node.js
if ! command -v node &> /dev/null; then
    error "Node.js не установлен. Установи: https://nodejs.org"
fi
success "Node.js: $(node --version)"

# Check npm
if ! command -v npm &> /dev/null; then
    error "npm не установлен"
fi
success "npm: $(npm --version)"

# Check Flutter
if ! command -v flutter &> /dev/null; then
    error "Flutter не установлен. Установи: https://flutter.dev"
fi
success "Flutter: $(flutter --version | head -n 1)"

# Check Dart
if ! command -v dart &> /dev/null; then
    error "Dart не установлен"
fi
success "Dart: $(dart --version 2>&1 | head -n 1)"

echo ""
info "Установка Firebase CLI..."

# Install/update Firebase CLI
if ! command -v firebase &> /dev/null; then
    npm install -g firebase-tools
    success "Firebase CLI установлен"
else
    warning "Firebase CLI уже установлен: $(firebase --version)"
    read -p "Обновить до последней версии? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        npm update -g firebase-tools
        success "Firebase CLI обновлён"
    fi
fi

echo ""
info "Авторизация в Firebase..."

# Login to Firebase
if ! firebase projects:list &> /dev/null; then
    firebase login
    success "Авторизация успешна"
else
    success "Уже авторизован"
fi

echo ""
info "Установка FlutterFire CLI..."

# Install FlutterFire CLI
if ! command -v flutterfire &> /dev/null; then
    dart pub global activate flutterfire_cli
    success "FlutterFire CLI установлен"
    
    # Add to PATH
    warning "Добавь в PATH (если не добавлено):"
    echo 'export PATH="$PATH":"$HOME/.pub-cache/bin"'
    echo ""
    read -p "Нажми Enter чтобы продолжить..."
else
    success "FlutterFire CLI уже установлен"
fi

echo ""
info "Список Firebase проектов:"
firebase projects:list

echo ""
read -p "Введи Firebase Project ID (или создай новый): " FIREBASE_PROJECT

if [ -z "$FIREBASE_PROJECT" ]; then
    error "Project ID не может быть пустым"
fi

echo ""
info "Настройка Firebase для проекта: $FIREBASE_PROJECT"

# Configure FlutterFire
flutterfire configure --project="$FIREBASE_PROJECT"

if [ $? -eq 0 ]; then
    success "Firebase настроен успешно!"
    success "Файл firebase_options.dart создан"
else
    error "Ошибка при настройке Firebase"
fi

echo ""
info "Обновление main.dart..."

# Backup main.dart
cp lib/main.dart lib/main.dart.backup
success "Backup создан: lib/main.dart.backup"

# Check if firebase_options is already imported
if grep -q "import 'firebase_options.dart'" lib/main.dart; then
    success "Импорт firebase_options.dart уже добавлен"
else
    # Add import after other imports
    sed -i '' "/import 'package:firebase_core\/firebase_core.dart';/a\\
import 'firebase_options.dart';\\
" lib/main.dart
    success "Добавлен импорт: import 'firebase_options.dart';"
fi

# Replace Firebase initialization
if grep -q "DefaultFirebaseOptions.currentPlatform" lib/main.dart; then
    success "Firebase.initializeApp уже использует DefaultFirebaseOptions"
else
    # Replace the Firebase initialization block
    sed -i '' 's/await Firebase\.initializeApp([^)]*)/await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)/g' lib/main.dart
    success "Обновлён Firebase.initializeApp"
fi

echo ""
info "Установка зависимостей..."

flutter pub get

success "Зависимости установлены"

echo ""
echo "================================"
success "🎉 Firebase настроен успешно!"
echo "================================"
echo ""

info "Следующие шаги:"
echo "1. Проверь lib/main.dart - импорт должен быть на месте"
echo "2. Запусти приложение:"
echo "   flutter run -d chrome"
echo "3. Включи методы авторизации в Firebase Console:"
echo "   - Email/Password"
echo "   - Google Sign-In"
echo "   - Apple Sign-In (для iOS)"
echo ""
info "Подробная инструкция: FIREBASE_SETUP_COMPLETE.md"
echo ""

read -p "Открыть Firebase Console? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "https://console.firebase.google.com/project/$FIREBASE_PROJECT/overview"
fi

exit 0
