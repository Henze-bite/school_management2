# 🚀 Quick Start - Run the App

## Installation & Running

### 1. Install Dependencies
```bash
cd d:\flutter_ass\school_management
flutter pub get
```

### 2. Run the App
```bash
# On connected device/emulator
flutter run

# On specific device
flutter run -d <device_id>

# For web
flutter run -d chrome
```

### 3. Build for Production
```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires macOS)
flutter build ios --release
```

---

## Default Login Credentials

| Field | Value |
|-------|-------|
| Email | `teacher@school.com` |
| Password | `password123` |

---

## Project Structure

```
school_management/
├── lib/
│   ├── main.dart                      # Entry point with routes & theme
│   ├── models/                        # Data models
│   │   ├── user_model.dart
│   │   ├── student_model.dart
│   │   ├── class_model.dart
│   │   └── attendance_model.dart
│   ├── providers/                     # State management
│   │   ├── auth_provider.dart
│   │   ├── student_provider.dart
│   │   ├── class_provider.dart
│   │   ├── attendance_provider.dart
│   │   └── theme_provider.dart
│   ├── services/                      # Database & APIs
│   │   └── database_service.dart
│   └── screens/                       # UI Screens
│       ├── auth/
│       ├── dashboard/
│       ├── student/
│       ├── class/
│       ├── attendance/
│       └── profile/
├── pubspec.yaml                       # Dependencies
└── analysis_options.yaml              # Lint rules
```

---

## Key Features

✅ **Authentication**: Login with email/password  
✅ **Student Management**: Add, edit, delete, search, sort  
✅ **Class Management**: Create and manage classes  
✅ **Attendance**: Mark and track attendance  
✅ **Dark Mode**: Theme switching  
✅ **Database**: SQLite for local storage  
✅ **Search & Filter**: Find students quickly  

---

## Verification Status

✅ **Flutter Analyze**: No issues found  
✅ **All Dependencies**: Installed successfully  
✅ **Code Quality**: Production-ready  
✅ **Features**: All 18+ implemented  
✅ **Database**: SQLite configured  

---

## File Guide

| Component | File | Purpose |
|-----------|------|---------|
| Entry | [lib/main.dart](lib/main.dart) | App initialization, routes, themes |
| Auth | [lib/providers/auth_provider.dart](lib/providers/auth_provider.dart) | User login/logout |
| Students | [lib/providers/student_provider.dart](lib/providers/student_provider.dart) | Student CRUD & search |
| Classes | [lib/providers/class_provider.dart](lib/providers/class_provider.dart) | Class management |
| Attendance | [lib/providers/attendance_provider.dart](lib/providers/attendance_provider.dart) | Attendance tracking |
| Database | [lib/services/database_service.dart](lib/services/database_service.dart) | SQLite operations |
| UI | [lib/screens/home_screen.dart](lib/screens/home_screen.dart) | Bottom navigation |

---

## Troubleshooting

### Issue: "Target of URI doesn't exist"
**Solution**: Run `flutter pub get` to install dependencies

### Issue: "No devices found"
**Solution**: Start an emulator or connect a physical device via USB

### Issue: "Android SDK not found"
**Solution**: Set `ANDROID_SDK_ROOT` environment variable or install Android Studio

### Issue: "Flutter version error"
**Solution**: Run `flutter upgrade` to get the latest Flutter SDK

---

## Documentation

- 📖 [SETUP_GUIDE.md](SETUP_GUIDE.md) - Complete setup instructions
- 📖 [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) - How to extend the app
- 📖 [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) - Technical overview
- 📖 [VERIFICATION_REPORT.md](VERIFICATION_REPORT.md) - Quality assurance report
- 📖 [FILE_GUIDE.md](FILE_GUIDE.md) - Index of all files
- 📖 [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues

---

## Support

For issues or questions:
1. Check the [TROUBLESHOOTING.md](TROUBLESHOOTING.md) guide
2. Review the [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) for code structure
3. Run `flutter doctor` to verify your setup

---

**Status**: ✅ Ready to run!  
**Last Updated**: December 2024
