# The lib Folder and main.dart

The `lib/` folder is where your Flutter app lives. It's the heart of your project, containing all the Dart code that makes your app work.

## 📁 The lib Folder

### What is lib/?

- Short for "library"
- Contains **all your Dart code**
- Where you'll spend most of your development time
- This is where the magic happens! ✨

### Typical lib/ Structure

```
lib/
├── main.dart           # Entry point of your app
├── screens/            # All your screen/page widgets
│   ├── home_screen.dart
│   ├── profile_screen.dart
│   └── settings_screen.dart
├── widgets/            # Reusable UI components
│   ├── custom_button.dart
│   └── loading_spinner.dart
├── models/             # Data models/classes
│   ├── user.dart
│   └── product.dart
├── services/           # API calls, database, etc.
│   ├── api_service.dart
│   └── auth_service.dart
├── utils/              # Helper functions
│   └── constants.dart
└── providers/          # State management (if using Provider)
    └── user_provider.dart
```

**Note:** This structure is recommended but not mandatory. Organize based on your project needs!

## 🚀 Understanding main.dart

### What is main.dart?

The **entry point** of your Flutter app - where execution begins. Every Flutter app must have this file.

### Basic main.dart Structure

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

## 🔍 Breaking Down main.dart

### 1. **Imports**

```dart
import 'package:flutter/material.dart';
```

- Imports Flutter's Material Design widgets
- `material.dart` gives you access to widgets like `Scaffold`, `AppBar`, `Text`, etc.

### 2. **main() Function**

```dart
void main() {
  runApp(const MyApp());
}
```

- **The starting point** of your app
- `runApp()` takes a widget and makes it the root of your app
- Execution starts here when you launch the app

### 3. **MyApp Widget (Root Widget)**

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Home'),
    );
  }
}
```

**Key components:**
- `MaterialApp`: Sets up Material Design for your app
- `title`: App name (shown in task switcher)
- `theme`: Configures colors, fonts, etc.
- `home`: The first screen users see

### 4. **StatefulWidget vs StatelessWidget**

**StatelessWidget:**
- Doesn't change over time
- No internal state
- Example: Static text, icons

**StatefulWidget:**
- Can change based on user interaction
- Has mutable state
- Example: Counter, form inputs

## 🎯 Common Patterns in main.dart

### Simple Navigation Setup

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
```

### Theme Configuration

```dart
theme: ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.light,
  fontFamily: 'Roboto',
  textTheme: TextTheme(
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
  ),
),
darkTheme: ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.blue,
),
themeMode: ThemeMode.system, // Follows system theme
```

### Initialization Tasks

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Load saved preferences
  await SharedPreferences.getInstance();
  
  runApp(const MyApp());
}
```

## 🏗️ Organizing Your Code

### Problem: Everything in main.dart

```dart
// ❌ Don't do this - main.dart becomes huge!
void main() { runApp(MyApp()); }

class MyApp extends StatelessWidget { ... }
class HomeScreen extends StatefulWidget { ... }
class ProfileScreen extends StatefulWidget { ... }
class SettingsScreen extends StatefulWidget { ... }
// ... 1000 more lines
```

### Solution: Separate Files

**main.dart:**
```dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: const HomeScreen(),
    );
  }
}
```

**lib/screens/home_screen.dart:**
```dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Welcome!')),
    );
  }
}
```

## 💡 Best Practices

1. **Keep main.dart minimal**: Only app configuration and root widget
2. **Separate screens into files**: One screen = one file
3. **Use meaningful names**: `home_screen.dart` not `screen1.dart`
4. **Follow naming conventions**:
   - Files: `snake_case.dart`
   - Classes: `PascalCase`
   - Variables: `camelCase`
5. **Import only what you need**: Avoid `import 'package:flutter/cupertino.dart'` if you're using Material

## 🔧 File Organization Tips

### Small Project (< 10 screens)

```
lib/
├── main.dart
├── home_screen.dart
├── profile_screen.dart
└── settings_screen.dart
```

### Medium Project (10-50 screens)

```
lib/
├── main.dart
├── screens/
├── widgets/
├── models/
└── services/
```

### Large Project (50+ screens)

```
lib/
├── main.dart
├── features/
│   ├── auth/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── services/
│   └── profile/
│       ├── screens/
│       ├── widgets/
│       └── services/
├── shared/
│   ├── widgets/
│   └── utils/
└── core/
    ├── theme/
    └── constants/
```

## ✅ Quick Checklist

- [ ] Understand that `lib/` contains all your Dart code
- [ ] Know that `main.dart` is the entry point
- [ ] Keep `main.dart` clean and minimal
- [ ] Organize code into logical folders as project grows
- [ ] One widget per file for better organization
- [ ] Use proper naming conventions

## 🎓 Learning Exercise

Try this:
1. Create a new file `lib/screens/welcome_screen.dart`
2. Create a simple `WelcomeScreen` widget
3. Import it in `main.dart`
4. Set it as the `home` in `MaterialApp`
5. Run the app!

---

**Previous:** [Understanding pubspec.yaml](./02-understanding-pubspec-yaml.md)  
**Next:** [Flutter Widgets Basics](./04-flutter-widgets-basics.md)
