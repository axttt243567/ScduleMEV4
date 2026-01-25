# ScduleME v4

A Flutter-based scheduling and productivity application for Android.

## Features

- **Calendar** — View and manage schedules
- **Home Dashboard** — Daily overview and quick actions
- **Notes** — Document storage with support for PDFs, images, audio, and video
- **Attendance Tracker** — Track attendance records
- **AI Chat (Nexus AI)** — Integrated AI assistant
- **Settings** — App configuration and preferences

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter |
| Language | Dart |
| Platform | Android |

## Project Structure

```
ScduleMEv4o1/
├── android/        # Android platform configuration
├── lib/
│   ├── main.dart   # Application entry point
│   ├── pages/      # Screen implementations
│   └── widgets/    # Reusable UI components
├── assets/         # Static resources
└── pubspec.yaml    # Dependency manifest
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Android Studio](https://developer.android.com/studio) with Android Emulator
- [Git](https://git-scm.com/downloads)

### Installation

```bash
# Clone repository
git clone https://github.com/USERNAME/ScduleMEV4.git
cd ScduleMEV4

# Install dependencies
flutter pub get

# Run on Android emulator
flutter run
```

## Development

| Config | Value |
|--------|-------|
| Target Platform | Android |
| Min SDK | See `android/app/build.gradle` |
| Hot Reload | `r` in terminal |
| Hot Restart | `R` in terminal |

## Build

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

## Resources

- [Flutter Docs](https://docs.flutter.dev/)
- [Dart Docs](https://dart.dev/guides)
- [Android Emulator](https://developer.android.com/studio/run/emulator)

## License

MIT
