# State Management Introduction

State management is one of the most important concepts in Flutter. Let's understand what state is and how to manage it effectively!

## What is State?

**State** is any data that can change over time in your app.

### Examples of State:
- A counter value that increases when you click a button
- Whether a checkbox is checked or unchecked
- User login status (logged in or logged out)
- Items in a shopping cart
- Current theme (light or dark mode)
- Data loaded from an API

### Not State:
- Static text that never changes
- Hardcoded constants
- App configuration

## Why State Management Matters

Without proper state management:
- Your app won't respond to user interactions
- Data won't sync across different screens
- Code becomes messy and hard to maintain
- Performance suffers

With good state management:
- UI updates automatically when data changes
- Data is accessible throughout your app
- Code is organized and maintainable
- Better performance and user experience

## Types of State

### 1. Local State (Widget State)

State that belongs to a single widget.

**Example:** A counter in one screen

```dart
class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _counter = 0;  // Local state

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        child: Text('Count: $_counter'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

**When to use:**
- State only affects one widget
- No other widgets need this data
- Simple, temporary data

### 2. App State (Global State)

State that needs to be shared across multiple widgets/screens.

**Examples:**
- User authentication status
- Shopping cart items
- App theme preferences
- User profile data

## setState() - The Foundation

The most basic way to update state.

### How setState() Works

```dart
class ToggleExample extends StatefulWidget {
  @override
  State<ToggleExample> createState() => _ToggleExampleState();
}

class _ToggleExampleState extends State<ToggleExample> {
  bool _isOn = false;

  void _toggle() {
    setState(() {
      _isOn = !_isOn;  // Change state
    });
    // Widget automatically rebuilds!
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _isOn,
      onChanged: (value) {
        setState(() {
          _isOn = value;
        });
      },
    );
  }
}
```

### Important Rules:
1. **Only call `setState()` in StatefulWidgets**
2. **Always update state inside `setState(() { ... })`**
3. **Don't call `setState()` during build**

### Common setState() Mistake

```dart
// WRONG - State doesn't update UI
void _wrongIncrement() {
  _counter++;  // UI won't update!
}

// CORRECT - UI updates
void _correctIncrement() {
  setState(() {
    _counter++;  // UI updates!
  });
}
```

## Widget Tree and State

Understanding how state flows through your app.

```
MaterialApp
  └── HomeScreen (has user data)
      ├── HeaderWidget (needs user name)
      ├── BodyWidget
      │   └── ProfileWidget (needs user data)
      └── FooterWidget (needs user data)
```

**Problem:** How do we share user data across these widgets?

### Solutions:

#### 1. Constructor Passing (Simple but tedious)

```dart
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = 'John Doe';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HeaderWidget(userName: userName),
        ProfileWidget(userName: userName),
        FooterWidget(userName: userName),
      ],
    );
  }
}

class HeaderWidget extends StatelessWidget {
  final String userName;
  const HeaderWidget({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Text('Welcome, $userName');
  }
}
```

**Good for:** Small apps, close widgets  
**Bad for:** Deep widget trees, many widgets needing same data

## State Management Solutions

As apps grow, you need better solutions than just `setState()`.

### Popular State Management Approaches:

| Approach | Complexity | Best For |
|----------|-----------|----------|
| **setState** | Easiest | Local state, simple apps |
| **InheritedWidget** | Moderate | Understanding Flutter internals |
| **Provider** | Moderate | Most apps, recommended by Flutter team |
| **Riverpod** | Advanced | Type-safe, modern apps |
| **Bloc** | Advanced | Large apps, complex business logic |
| **GetX** | Moderate | Quick development, all-in-one |

### Provider - Most Common Choice

**Why Provider?**
- Recommended by Flutter team
- Easy to learn
- Works well with small and large apps
- Good performance

#### Quick Provider Example

**1. Add dependency in `pubspec.yaml`:**
```yaml
dependencies:
  provider: ^6.0.5
```

**2. Create a model:**
```dart
import 'package:flutter/material.dart';

class CounterModel extends ChangeNotifier {
  int _count = 0;
  
  int get count => _count;
  
  void increment() {
    _count++;
    notifyListeners();  // Tell widgets to rebuild
  }
}
```

**3. Provide the model:**
```dart
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CounterModel(),
      child: const MyApp(),
    ),
  );
}
```

**4. Use in widgets:**
```dart
class CounterDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Listen to changes
    final counter = context.watch<CounterModel>();
    
    return Text('Count: ${counter.count}');
  }
}

class IncrementButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access without listening
    final counter = context.read<CounterModel>();
    
    return ElevatedButton(
      onPressed: counter.increment,
      child: const Text('Increment'),
    );
  }
}
```

## Real-World Example: Theme Switcher

```dart
// 1. Theme Model
class ThemeModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDark => _themeMode == ThemeMode.dark;
  
  void toggleTheme() {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

// 2. Provide at app level
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeModel(),
      child: const MyApp(),
    ),
  );
}

// 3. Use in MaterialApp
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeModel = context.watch<ThemeModel>();
    
    return MaterialApp(
      themeMode: themeModel.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

// 4. Toggle button anywhere in app
class ThemeToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeModel = context.read<ThemeModel>();
    
    return IconButton(
      icon: Icon(
        themeModel.isDark ? Icons.light_mode : Icons.dark_mode,
      ),
      onPressed: themeModel.toggleTheme,
    );
  }
}
```

## Best Practices

### 1. Choose the Right Solution

```
Simple local state (checkbox, text field)
  → Use setState()

App-wide state (user, theme, settings)
  → Use Provider/Riverpod

Complex business logic with events
  → Use Bloc
```

### 2. Separate UI and Logic

```dart
// Bad - Logic in widget
class _MyWidgetState extends State<MyWidget> {
  void _complexCalculation() {
    // 100 lines of business logic
  }
}

// Good - Logic in model
class MyModel extends ChangeNotifier {
  void complexCalculation() {
    // Business logic here
  }
}
```

### 3. Keep State Immutable When Possible

```dart
// Mutable
List<String> items = ['a', 'b'];
items.add('c');  // Modifying directly

// Immutable
List<String> items = ['a', 'b'];
items = [...items, 'c'];  // Creating new list
```

### 4. Don't Rebuild Unnecessarily

```dart
// Entire widget rebuilds
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataModel>();  // Watches everything
    
    return Column(
      children: [
        ExpensiveWidget(),  // Rebuilds even if unchanged
        Text(data.value),
      ],
    );
  }
}

// Only necessary parts rebuild
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ExpensiveWidget(),  // Won't rebuild
        Consumer<DataModel>(
          builder: (context, data, child) {
            return Text(data.value);  // Only this rebuilds
          },
        ),
      ],
    );
  }
}
```

## Learning Path

1. **Start with setState()** - Master the basics
2. **Learn Provider** - Industry standard for most apps
3. **Explore others** - Try Riverpod or Bloc when ready
4. **Practice** - Build real apps to understand tradeoffs

## Common Patterns

### Loading States

```dart
enum LoadingState { initial, loading, loaded, error }

class DataModel extends ChangeNotifier {
  LoadingState _state = LoadingState.initial;
  List<String> _data = [];
  String? _error;
  
  LoadingState get state => _state;
  List<String> get data => _data;
  String? get error => _error;
  
  Future<void> fetchData() async {
    _state = LoadingState.loading;
    notifyListeners();
    
    try {
      _data = await apiCall();
      _state = LoadingState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = LoadingState.error;
    }
    notifyListeners();
  }
}
```

## Key Takeaways

- State = data that changes over time
- Use `setState()` for local widget state
- Use Provider/Riverpod for app-wide state
- Keep UI and business logic separate
- Don't over-engineer - start simple
- Rebuild only what needs to update

## Next Steps

1. Practice with `setState()` in small projects
2. Install and try Provider
3. Build a todo app or shopping cart
4. Explore advanced patterns as needed

---

**Previous:** [Flutter Widgets Basics](./04-flutter-widgets-basics.md)  
**Back to start:** [README](./README.md)
