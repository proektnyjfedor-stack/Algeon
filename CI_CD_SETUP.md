# 🔄 CI/CD Setup для MathPilot

## Цель
Автоматизировать:
- Тестирование
- Сборку
- Деплой в App Store / Google Play
- Web hosting

---

## GitHub Actions Workflows

### 1. Test & Build (на каждый push)

Создай `.github/workflows/test.yml`:

```yaml
name: Test & Build

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    name: Run Tests
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.19.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Analyze code
      run: flutter analyze
    
    - name: Run tests
      run: flutter test
    
    - name: Check formatting
      run: dart format --set-exit-if-changed .

  build-android:
    name: Build Android APK
    runs-on: ubuntu-latest
    needs: test
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.19.0'
    
    - name: Setup Java
      uses: actions/setup-java@v3
      with:
        distribution: 'zulu'
        java-version: '17'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Build APK
      run: flutter build apk --release
    
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: android-apk
        path: build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    name: Build iOS
    runs-on: macos-latest
    needs: test
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.19.0'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Build iOS (no codesign)
      run: flutter build ios --release --no-codesign
    
    - name: Upload iOS build
      uses: actions/upload-artifact@v3
      with:
        name: ios-build
        path: build/ios/iphoneos/*.app

  build-web:
    name: Build Web
    runs-on: ubuntu-latest
    needs: test
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.19.0'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Build Web
      run: flutter build web --release
    
    - name: Upload Web build
      uses: actions/upload-artifact@v3
      with:
        name: web-build
        path: build/web
```

---

### 2. Deploy to Firebase Hosting (Web)

Создай `.github/workflows/deploy-web.yml`:

```yaml
name: Deploy Web to Firebase

on:
  push:
    branches: [ main ]
    paths:
      - 'lib/**'
      - 'web/**'
      - 'pubspec.yaml'

jobs:
  deploy:
    name: Deploy to Firebase Hosting
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.19.0'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Build Web
      run: flutter build web --release
    
    - name: Deploy to Firebase
      uses: FirebaseExtended/action-hosting-deploy@v0
      with:
        repoToken: '${{ secrets.GITHUB_TOKEN }}'
        firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
        channelId: live
        projectId: mathpilot-prod
```

---

### 3. Deploy to App Store (iOS)

Создай `.github/workflows/deploy-ios.yml`:

```yaml
name: Deploy iOS to App Store

on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  deploy:
    name: Deploy to App Store
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.19.0'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Setup certificates
      env:
        IOS_CERTIFICATE: ${{ secrets.IOS_CERTIFICATE }}
        IOS_PROVISIONING_PROFILE: ${{ secrets.IOS_PROVISIONING_PROFILE }}
      run: |
        echo "$IOS_CERTIFICATE" | base64 --decode > certificate.p12
        echo "$IOS_PROVISIONING_PROFILE" | base64 --decode > profile.mobileprovision
        
        # Install certificate
        security create-keychain -p "" build.keychain
        security import certificate.p12 -k build.keychain -P "" -A
        security set-key-partition-list -S apple-tool:,apple: -s -k "" build.keychain
        security list-keychains -s build.keychain
        security default-keychain -s build.keychain
        security unlock-keychain -p "" build.keychain
        
        # Install provisioning profile
        mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
        cp profile.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/
    
    - name: Build IPA
      run: flutter build ipa --release
    
    - name: Upload to App Store Connect
      env:
        APP_STORE_CONNECT_API_KEY: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
      run: |
        xcrun altool --upload-app \
          --type ios \
          --file build/ios/ipa/*.ipa \
          --apiKey $APP_STORE_CONNECT_API_KEY
```

---

### 4. Deploy to Google Play (Android)

Создай `.github/workflows/deploy-android.yml`:

```yaml
name: Deploy Android to Google Play

on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  deploy:
    name: Deploy to Google Play
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.19.0'
    
    - name: Setup Java
      uses: actions/setup-java@v3
      with:
        distribution: 'zulu'
        java-version: '17'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Setup signing key
      env:
        ANDROID_KEYSTORE: ${{ secrets.ANDROID_KEYSTORE }}
        KEY_PROPERTIES: ${{ secrets.KEY_PROPERTIES }}
      run: |
        echo "$ANDROID_KEYSTORE" | base64 --decode > android/app/keystore.jks
        echo "$KEY_PROPERTIES" > android/key.properties
    
    - name: Build AAB
      run: flutter build appbundle --release
    
    - name: Upload to Google Play
      uses: r0adkll/upload-google-play@v1
      with:
        serviceAccountJsonPlainText: ${{ secrets.SERVICE_ACCOUNT_JSON }}
        packageName: com.mathpilot.app
        releaseFiles: build/app/outputs/bundle/release/app-release.aab
        track: production
        status: completed
```

---

## Secrets Setup

### GitHub Secrets

Добавь в Settings → Secrets and variables → Actions:

**Firebase**:
- `FIREBASE_SERVICE_ACCOUNT` - JSON ключ сервисного аккаунта

**iOS**:
- `IOS_CERTIFICATE` - Base64 p12 сертификата
- `IOS_PROVISIONING_PROFILE` - Base64 provisioning profile
- `APP_STORE_CONNECT_API_KEY` - API ключ

**Android**:
- `ANDROID_KEYSTORE` - Base64 keystore.jks
- `KEY_PROPERTIES` - Содержимое key.properties
- `SERVICE_ACCOUNT_JSON` - Google Play Service Account JSON

---

## Настройка Firebase Hosting

```bash
# Установи Firebase CLI
npm install -g firebase-tools

# Войди
firebase login

# Инициализируй hosting
firebase init hosting

# Выбери:
# - Existing project: mathpilot-prod
# - Public directory: build/web
# - Single-page app: Yes
# - Set up automatic builds: No (мы используем GitHub Actions)
```

Создай `firebase.json`:

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "public, max-age=31536000"
          }
        ]
      }
    ]
  }
}
```

---

## Fastlane (альтернатива для iOS/Android)

### Установка

```bash
# iOS
cd ios
bundle exec fastlane init

# Android
cd android
bundle exec fastlane init
```

### iOS Fastfile

`ios/fastlane/Fastfile`:

```ruby
platform :ios do
  desc "Build and upload to App Store"
  lane :release do
    increment_build_number
    build_app(
      scheme: "Runner",
      export_method: "app-store"
    )
    upload_to_app_store(
      skip_screenshots: true,
      skip_metadata: true
    )
  end
  
  desc "Build and upload to TestFlight"
  lane :beta do
    build_app(
      scheme: "Runner",
      export_method: "app-store"
    )
    upload_to_testflight
  end
end
```

### Android Fastfile

`android/fastlane/Fastfile`:

```ruby
platform :android do
  desc "Build and upload to Google Play"
  lane :release do
    increment_version_code
    gradle(
      task: "bundle",
      build_type: "Release"
    )
    upload_to_play_store(
      track: "production",
      aab: "app/build/outputs/bundle/release/app-release.aab"
    )
  end
  
  desc "Build and upload to Internal Testing"
  lane :beta do
    gradle(
      task: "bundle",
      build_type: "Release"
    )
    upload_to_play_store(
      track: "internal",
      aab: "app/build/outputs/bundle/release/app-release.aab"
    )
  end
end
```

---

## Version Bumping

Создай скрипт `scripts/bump_version.sh`:

```bash
#!/bin/bash

# Bump version for MathPilot

set -e

CURRENT_VERSION=$(grep "version:" pubspec.yaml | awk '{print $2}')
echo "Current version: $CURRENT_VERSION"

# Split version
VERSION_NUMBER=$(echo $CURRENT_VERSION | cut -d'+' -f1)
BUILD_NUMBER=$(echo $CURRENT_VERSION | cut -d'+' -f2)

# Increment build number
NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))

# Ask for version type
echo "Bump type:"
echo "1. Patch (0.0.x)"
echo "2. Minor (0.x.0)"
echo "3. Major (x.0.0)"
read -p "Choice: " CHOICE

case $CHOICE in
  1)
    NEW_VERSION=$(echo $VERSION_NUMBER | awk -F. '{print $1"."$2"."$3+1}')
    ;;
  2)
    NEW_VERSION=$(echo $VERSION_NUMBER | awk -F. '{print $1"."$2+1".0"}')
    ;;
  3)
    NEW_VERSION=$(echo $VERSION_NUMBER | awk -F. '{print $1+1".0.0"}')
    ;;
  *)
    echo "Invalid choice"
    exit 1
    ;;
esac

# Update pubspec.yaml
sed -i '' "s/version: $CURRENT_VERSION/version: $NEW_VERSION+$NEW_BUILD_NUMBER/" pubspec.yaml

echo "Updated to: $NEW_VERSION+$NEW_BUILD_NUMBER"

# Commit and tag
git add pubspec.yaml
git commit -m "Bump version to $NEW_VERSION+$NEW_BUILD_NUMBER"
git tag "v$NEW_VERSION"

echo "Don't forget to: git push && git push --tags"
```

---

## Monitoring & Alerts

### Crashlytics

```dart
// lib/main.dart

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  // Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  
  runApp(const MathPilotApp());
}
```

### Sentry (альтернатива)

```dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'YOUR_SENTRY_DSN';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(const MathPilotApp()),
  );
}
```

---

## Checklist

### Before first deploy:

- [ ] GitHub workflows created
- [ ] Secrets configured
- [ ] Firebase Hosting setup
- [ ] iOS certificates ready
- [ ] Android keystore created
- [ ] App Store Connect configured
- [ ] Google Play Console configured
- [ ] Crashlytics enabled
- [ ] Version bumping script tested

### On each release:

- [ ] Tests passing
- [ ] Version bumped
- [ ] Changelog updated
- [ ] Tag created
- [ ] Deploy triggered
- [ ] Monitor crash reports
- [ ] Check analytics

---

## Useful Commands

```bash
# Test workflow locally
act -j test

# Manual deploy
flutter build web --release
firebase deploy --only hosting

# Check build status
gh run list
gh run view <run-id>

# Re-run failed jobs
gh run rerun <run-id>
```

---

**Создано для MathPilot © 2025**
