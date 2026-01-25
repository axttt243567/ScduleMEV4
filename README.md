# ScduleME v4

A premium Flutter-based scheduling and productivity application for students, featuring an advanced AI chat assistant with 24+ rich content types.

## ✨ Features

### Core Modules
- **📅 Calendar** — Interactive calendar with event management
- **🏠 Home Dashboard** — Daily overview, quick actions, and widgets
- **📝 Notes** — Document storage with PDFs, images, audio, and video
- **📊 Attendance Tracker** — Track and visualize attendance records
- **🤖 AI Chat (Nexus AI)** — Advanced AI assistant with rich responses
- **⚙️ Settings** — App configuration and preferences

---

## 🤖 AI Chat - Content Block System

The Nexus AI chat features a powerful **multi-block response system** supporting 24+ content types. The AI can respond with charts, interactive elements, media, and more.

### 📊 Data Visualization

| Type | Description | Test Keyword |
|------|-------------|--------------|
| Bar Chart | Vertical bar graphs | `#bar` |
| Pie Chart | Donut-style pie charts with legend | `#pie` |
| Line Chart | Trend lines with area fill | `#line` |
| Radar Chart | Polygon skill/comparison charts | `#radar` |
| Progress Bars | Animated progress indicators | `#progress` |
| Timeline | Vertical event timeline | `#timeline` |

### 📝 Interactive Content

| Type | Description | Test Keyword |
|------|-------------|--------------|
| Quiz | Multiple choice with answer reveal | `#quiz` |
| Checklist | Tappable to-do items | `#checklist` |
| Collapsible | Expandable/collapsible sections | — |
| Data Table | Scrollable data tables | `#table` |
| Cards Carousel | Swipeable info cards | `#cards` |

### 🎵 Media

| Type | Description | Test Keyword |
|------|-------------|--------------|
| Audio Player | Play/pause with progress bar | `#audio` |
| Video Player | Video embed with thumbnail | `#video` |
| File Attachment | File preview with download | — |
| Voice Message | Waveform visualization | — |

### 🔗 Actions & Links

| Type | Description | Test Keyword |
|------|-------------|--------------|
| Quick Actions | Action button chips | `#actions` |
| Contact Card | Contact info with call/email | `#contact` |
| Calendar Event | Event card with "Add" button | `#event` |

### 🎨 Rich Formatting

| Type | Description | Test Keyword |
|------|-------------|--------------|
| Markdown | Formatted text rendering | — |
| Math Equation | Mathematical formula display | — |
| Code Block | Syntax highlighted code | `#code` |

### 🌟 Bonus Widgets

| Type | Description | Test Keyword |
|------|-------------|--------------|
| Weather | Weather card with icon | `#weather` |
| Countdown | Live countdown timer | `#countdown` |
| Flashcards | Flip-to-reveal study cards | `#flash` |
| PDF Preview | Document preview with actions | — |
| Interactive Map | Zoomable map with markers | `#map` |

### 🧪 Developer Testing

Use these keywords in the chat to test content types:

```
#all        → Shows ALL 24 content types with labels
#bar        → Bar chart demo
#pie        → Pie chart demo
#line       → Line chart demo
#radar      → Radar chart demo
#progress   → Progress bars demo
#timeline   → Timeline demo
#quiz       → Interactive quiz
#checklist  → Checklist demo
#table      → Data table demo
#cards      → Cards carousel
#audio      → Audio player demo
#video      → Video player demo
#contact    → Contact card demo
#event      → Calendar event demo
#actions    → Quick actions demo
#weather    → Weather widget
#countdown  → Countdown timer
#flash      → Flashcards demo
#map        → Interactive map
#code       → Code block demo
#imgN       → N images (e.g., #img3)
#multi      → Mixed text/images
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter 3.x |
| Language | Dart |
| Platform | Android |
| Charts | fl_chart |
| Maps | flutter_map + latlong2 |
| State | setState (local) |

---

## 📁 Project Structure

```
ScduleMEv4o1/
├── android/              # Android platform configuration
├── lib/
│   ├── main.dart         # Application entry point
│   ├── pages/
│   │   ├── ai_chat_page.dart    # AI Chat with 24+ content types
│   │   ├── home_page.dart       # Home dashboard
│   │   ├── calendar_page.dart   # Calendar view
│   │   ├── notes_page.dart      # Notes management
│   │   └── ...
│   └── widgets/          # Reusable UI components
├── assets/               # Static resources (images, fonts)
└── pubspec.yaml          # Dependency manifest
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x recommended)
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

### Hot Reload

| Command | Action |
|---------|--------|
| `r` | Hot Reload (preserves state) |
| `R` | Hot Restart (resets state) |
| `q` | Quit |

---

## 📦 Build

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (Play Store)
flutter build appbundle --release
```

---

## 🎨 Design System

### Colors
| Name | Hex | Usage |
|------|-----|-------|
| Background | `#0A0A0C` | App background |
| Surface | `#16161E` | Cards, containers |
| Border | `#27272A` | Dividers, borders |
| Primary | `#3B82F6` | Blue accent |
| Secondary | `#8B5CF6` | Purple accent |
| Success | `#10B981` | Green accent |
| Warning | `#F59E0B` | Orange accent |
| Error | `#EF4444` | Red accent |

### Typography
- Primary font: System default
- Code font: Monospace

---

## 📚 Dependencies

```yaml
dependencies:
  flutter_map: ^6.0.0      # Interactive maps
  latlong2: ^0.9.0         # Geo coordinates
  fl_chart: ^0.69.2        # Charts (bar, pie, line, radar)
```

---

## 📄 License

MIT License - See [LICENSE](LICENSE) for details.

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing`)
5. Open a Pull Request

---

**Made with ❤️ using Flutter**
