# Flutter Widgets Basics

In Flutter, **everything is a widget**. Understanding widgets is the key to building Flutter apps. Let's break it down from the ground up!

## 🎯 What is a Widget?

A widget is a **description of part of your user interface**.

Think of widgets as:
- 🧱 Building blocks of your UI
- 📦 Reusable components
- 🎨 Both visible (buttons, text) and invisible (layouts, padding)

### Simple Analogy

Building a Flutter app is like building with LEGO:
- Each LEGO piece = A widget
- Combine pieces = Compose widgets
- Final creation = Your app

## 🔑 Two Types of Widgets

### 1. StatelessWidget

**Immutable** - doesn't change after it's built.

```dart
class Greeting extends StatelessWidget {
  final String name;
  
  const Greeting({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Text('Hello, $name!');
  }
}
```

**Use when:**
- Content doesn't change
- Just displays static information
- Examples: Icons, static text, images

### 2. StatefulWidget

**Mutable** - can change based on user interaction or data updates.

```dart
class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _count = 0;

  void _increment() {
    setState(() {
      _count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $_count'),
        ElevatedButton(
          onPressed: _increment,
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
```

**Use when:**
- Content changes over time
- Responds to user input
- Examples: Forms, counters, animated elements

## 🏗️ Essential Layout Widgets

### Container

A versatile box for styling and positioning.

```dart
Container(
  width: 200,
  height: 100,
  padding: const EdgeInsets.all(16),
  margin: const EdgeInsets.all(8),
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: const Text('Styled Container'),
)
```

### Column & Row

Arrange widgets vertically or horizontally.

```dart
// Vertical arrangement
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('First'),
    Text('Second'),
    Text('Third'),
  ],
)

// Horizontal arrangement
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    Icon(Icons.home),
    Icon(Icons.search),
    Icon(Icons.settings),
  ],
)
```

**Alignment Guide:**
- `mainAxisAlignment`: Along the main axis (vertical for Column, horizontal for Row)
- `crossAxisAlignment`: Along the cross axis (horizontal for Column, vertical for Row)

### Stack

Overlay widgets on top of each other.

```dart
Stack(
  children: [
    // Background
    Container(color: Colors.blue, width: 300, height: 300),
    
    // Positioned on top
    Positioned(
      top: 20,
      right: 20,
      child: Icon(Icons.favorite, color: Colors.red),
    ),
  ],
)
```

### Expanded & Flexible

Control how widgets fill available space.

```dart
Row(
  children: [
    Expanded(
      flex: 2,
      child: Container(color: Colors.red, height: 50),
    ),
    Expanded(
      flex: 1,
      child: Container(color: Colors.blue, height: 50),
    ),
  ],
)
// Red container takes 2/3 of width, blue takes 1/3
```

## 🎨 Common UI Widgets

### Text

```dart
Text(
  'Hello Flutter!',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
    letterSpacing: 1.2,
  ),
  textAlign: TextAlign.center,
)
```

### Image

```dart
// From assets
Image.asset('assets/images/logo.png')

// From network
Image.network('https://example.com/image.jpg')

// With sizing
Image.asset(
  'assets/images/logo.png',
  width: 100,
  height: 100,
  fit: BoxFit.cover,
)
```

### Icon

```dart
Icon(
  Icons.favorite,
  color: Colors.red,
  size: 48,
)
```

### Buttons

```dart
// Elevated (raised) button
ElevatedButton(
  onPressed: () {
    print('Button pressed!');
  },
  child: const Text('Click Me'),
)

// Text button
TextButton(
  onPressed: () {},
  child: const Text('Text Button'),
)

// Icon button
IconButton(
  icon: const Icon(Icons.favorite),
  onPressed: () {},
)

// Outlined button
OutlinedButton(
  onPressed: () {},
  child: const Text('Outlined'),
)
```

### TextField (Input)

```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Enter your name',
    hintText: 'John Doe',
    prefixIcon: Icon(Icons.person),
    border: OutlineInputBorder(),
  ),
  onChanged: (value) {
    print('Input: $value');
  },
)
```

## 📱 Scaffold - The App Structure

Most screens use `Scaffold` as the base.

```dart
Scaffold(
  appBar: AppBar(
    title: const Text('My App'),
    actions: [
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {},
      ),
    ],
  ),
  body: Center(
    child: Text('Main Content'),
  ),
  floatingActionButton: FloatingActionButton(
    onPressed: () {},
    child: const Icon(Icons.add),
  ),
  drawer: Drawer(
    child: ListView(
      children: [
        DrawerHeader(child: Text('Menu')),
        ListTile(title: Text('Home')),
        ListTile(title: Text('Settings')),
      ],
    ),
  ),
  bottomNavigationBar: BottomNavigationBar(
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ],
  ),
)
```

## 🔄 ListView - Scrollable Lists

### Basic ListView

```dart
ListView(
  children: [
    ListTile(
      leading: Icon(Icons.person),
      title: Text('John Doe'),
      subtitle: Text('john@example.com'),
    ),
    ListTile(
      leading: Icon(Icons.person),
      title: Text('Jane Smith'),
      subtitle: Text('jane@example.com'),
    ),
  ],
)
```

### ListView.builder (For large lists)

```dart
ListView.builder(
  itemCount: 100,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text('Item $index'),
    );
  },
)
```

## 🎯 Widget Composition

The power of Flutter: **compose small widgets into big ones**.

```dart
class UserCard extends StatelessWidget {
  final String name;
  final String email;
  
  const UserCard({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            child: Text(name[0]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Usage:
UserCard(
  name: 'John Doe',
  email: 'john@example.com',
)
```

## 💡 Best Practices

1. **Break down complex UIs** into smaller widgets
2. **Use const constructors** when possible for performance
   ```dart
   const Text('Hello')  // ✅ Good
   Text('Hello')        // ⚠️ Works, but not optimized
   ```
3. **Extract reusable widgets** into separate classes
4. **Name widgets clearly**: `UserProfileCard` not `Card1`
5. **Keep build methods simple**: If it's complex, split it up

## 🚫 Common Mistakes

### 1. Forgetting const

```dart
// ❌ Creates new widget every rebuild
Text('Hello')

// ✅ Reuses same widget
const Text('Hello')
```

### 2. Not Using Keys for Lists

```dart
// ❌ Flutter might lose track of items
ListView.builder(
  itemBuilder: (context, index) => MyWidget(),
)

// ✅ Unique keys help Flutter track items
ListView.builder(
  itemBuilder: (context, index) => MyWidget(key: ValueKey(index)),
)
```

### 3. Deeply Nested Widgets

```dart
// ❌ Hard to read and maintain
return Container(
  child: Column(
    children: [
      Row(
        children: [
          Container(
            child: Column(
              // ... more nesting
            ),
          ),
        ],
      ),
    ],
  ),
);

// ✅ Extract into separate widgets
return Container(
  child: Column(
    children: [
      _buildHeader(),
      _buildBody(),
      _buildFooter(),
    ],
  ),
);
```

## ✅ Quick Reference

| Widget | Purpose |
|--------|---------|
| `Container` | Box with styling, padding, margin |
| `Column` | Vertical layout |
| `Row` | Horizontal layout |
| `Stack` | Overlay widgets |
| `Expanded` | Fill available space |
| `Text` | Display text |
| `Image` | Display images |
| `Icon` | Display icons |
| `ElevatedButton` | Raised button |
| `TextField` | Text input |
| `ListView` | Scrollable list |
| `Scaffold` | Basic app structure |

## 🎓 Practice Exercise

Try building this:

```
┌─────────────────────────┐
│     App Bar             │
├─────────────────────────┤
│                         │
│   [Icon]  Title         │
│           Subtitle      │
│                         │
│   [Icon]  Title         │
│           Subtitle      │
│                         │
└─────────────────────────┘
```

Hint: Use `Scaffold`, `AppBar`, and `ListView` with `ListTile` widgets!

---

**Previous:** [The lib Folder and main.dart](./03-lib-folder-and-main-dart.md)  
**Next:** [State Management Introduction](./05-state-management-intro.md)
