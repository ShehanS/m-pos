# Flutter BLoC App

A production-ready Flutter application featuring:
- **BLoC Pattern** for state management
- **Firebase** (Auth, Firestore, FCM)
- **Google Sign-In** + Email/Password auth
- **GoRouter** for navigation with custom animations
- **Multilingual**: English 🇬🇧 | Sinhala සිංහල 🇱🇰 | Tamil தமிழ் 🇱🇰
- **Functional Programming** with `dartz` (Either/Option)
- **Flutter Animate** for smooth animations
- **Google Fonts** + Noto Sans for multilingual typography
- Dark/Light theme support

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry + MultiBlocProvider
├── firebase_options.dart        # Firebase config (replace with yours)
│
├── bloc/
│   ├── auth/                    # AuthBloc (events, states, bloc)
│   ├── locale/                  # LocaleBloc (en/si/ta switching)
│   ├── theme/                   # ThemeBloc (dark/light toggle)
│   └── notification/            # NotificationBloc (FCM handling)
│
├── models/
│   └── user_model.dart          # UserModel with Firestore mapping
│
├── services/
│   ├── auth_service.dart        # Firebase Auth + Google Sign-In
│   └── notification_service.dart# FCM + local notifications
│
├── routes/
│   ├── app_router.dart          # GoRouter with auth redirects
│   └── route_names.dart         # Route constants
│
├── screens/
│   ├── splash/                  # Animated splash screen
│   ├── onboarding/              # 3-page onboarding with PageView
│   ├── auth/                    # Login, Register, ForgotPassword
│   ├── home/                    # Home with quick actions
│   ├── profile/                 # User profile with edit
│   └── settings/                # Theme + Language + Sign Out
│
├── widgets/                     # Shared widgets
│   ├── animated_gradient_button.dart
│   ├── custom_text_field.dart
│   ├── google_sign_in_button.dart
│   ├── language_selector.dart
│   └── notification_badge.dart
│
├── l10n/
│   └── app_localizations.dart   # Inline translations (en/si/ta)
│
└── theme/
    └── app_theme.dart           # Material 3 light + dark themes

l10n/
├── app_en.arb                   # English strings
├── app_si.arb                   # Sinhala strings
└── app_ta.arb                   # Tamil strings
```

---

## 🚀 Setup Guide

### 1. Clone & Install

```bash
git clone <repo>
cd flutter_bloc_app
flutter pub get
```

### 2. Firebase Setup

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (creates firebase_options.dart)
flutterfire configure
```

This replaces the placeholder `lib/firebase_options.dart` with your actual config.

In Firebase Console:
- Enable **Email/Password** Authentication
- Enable **Google Sign-In** (add SHA-1 fingerprint for Android)
- Enable **Cloud Firestore**
- Enable **Cloud Messaging**
- Download `google-services.json` → `android/app/`
- Download `GoogleService-Info.plist` → `ios/Runner/`

### 3. Android Setup

Add to `android/build.gradle`:
```gradle
classpath 'com.google.gms:google-services:4.4.0'
```

Add to `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'

android {
    minSdkVersion 21
    compileSdkVersion 34
}
```

### 4. iOS Setup

```bash
cd ios && pod install
```

In `ios/Runner/Info.plist`, add Google Sign-In URL scheme:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

### 5. Run

```bash
flutter run
```

---

## 🏗️ BLoC Architecture

```
UI → Event → BLoC → State → UI
              ↕
          Service Layer
              ↕
         Firebase/API
```

### Auth Flow (Functional Style with dartz)
```dart
// Returns Either<String, UserModel>
// Left = error message, Right = success
final result = await authService.signInWithEmail(
  email: email,
  password: password,
);

result.fold(
  (failure) => emit(AuthErrorState(message: failure)),
  (user) => emit(AuthAuthenticatedState(user: user)),
);
```

### Route Guards
```dart
// GoRouter redirect handles auth state
redirect: (context, state) {
  if (authState is AuthUnauthenticatedState && !isOnAuthPage) {
    return RouteNames.login;
  }
  if (authState is AuthAuthenticatedState && isOnAuthPage) {
    return RouteNames.home;
  }
  return null;
},
```

---

## 🌐 Localization

Three languages with inline maps (no codegen needed):
- **English** (`en`) — Default
- **Sinhala** (`si`) — සිංහල with NotoSansSinhala font
- **Tamil** (`ta`) — தமிழ் with NotoSansTamil font

To add a string:
1. Add to `_localizedStrings` map in `app_localizations.dart`
2. Add getter
3. Add to all 3 language maps

To use code generation instead:
```bash
flutter gen-l10n
```

---

## 🔔 FCM Setup

Firestore document per user stores FCM token:
```json
{
  "uid": "...",
  "email": "user@example.com",
  "fcmToken": "fCM_TOKEN_HERE"
}
```

Send notification from Firebase Console or via HTTP v1 API:
```bash
curl -X POST https://fcm.googleapis.com/v1/projects/YOUR_PROJECT/messages:send \
  -H "Authorization: Bearer ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "token": "FCM_TOKEN",
      "notification": {
        "title": "Hello!",
        "body": "Test notification"
      }
    }
  }'
```

---

## 📦 Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | BLoC state management |
| `go_router` | Declarative routing |
| `firebase_auth` | Authentication |
| `firebase_messaging` | Push notifications |
| `cloud_firestore` | Database |
| `google_sign_in` | Google OAuth |
| `dartz` | Functional programming (Either/Option) |
| `flutter_animate` | Animations |
| `google_fonts` | Typography |
| `shared_preferences` | Local storage |
| `equatable` | Value equality |
