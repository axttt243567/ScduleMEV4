# Understanding pubspec.yaml

The `pubspec.yaml` file is the configuration center of your Flutter project. Think of it as the blueprint that tells Flutter what your app needs to run.

## 🎯 What is pubspec.yaml?

- **Configuration file** for your Flutter project
- Written in YAML format (indentation matters!)
- Manages dependencies, assets, app metadata
- Similar to `package.json` in Node.js or `requirements.txt` in Python

## 📋 Basic Structure

```yaml
name: my_flutter_app
description: A new Flutter project
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
```

## 🔑 Key Sections Explained

### 1. **Project Metadata**

```yaml
name: my_flutter_app
description: A new Flutter project
version: 1.0.0+1
```

- `name`: Your app's package name (use lowercase with underscores)
- `description`: Brief description of your app
- `version`: App version (format: `major.minor.patch+buildNumber`)

### 2. **Environment**

```yaml
environment:
  sdk: '>=3.0.0 <4.0.0'
```

- Specifies Dart SDK version compatibility
- Ensures your app runs on compatible Dart versions

### 3. **Dependencies** 📦

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  provider: ^6.0.5
```

**What are dependencies?**
- External packages/libraries your app needs
- Like importing tools to make development easier
- Example: `http` for API calls, `provider` for state management

**Version Constraints:**
- `^1.1.0`: Compatible with 1.1.0 and newer (but < 2.0.0)
- `1.1.0`: Exact version only
- `>=1.1.0 <2.0.0`: Any version in this range

### 4. **Dev Dependencies** 🛠️

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
```

- Packages used only during development
- Not included in the final app
- Examples: testing tools, code formatters, linters

### 5. **Flutter Section**

```yaml
flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/logo.png
  
  fonts:
    - family: Roboto
      fonts:
        - asset: fonts/Roboto-Regular.ttf
        - asset: fonts/Roboto-Bold.ttf
          weight: 700
```

**Assets:** Images, JSON files, etc.
- Must declare all asset files or folders here
- Use forward slashes even on Windows

**Fonts:** Custom fonts for your app
- Specify font family and file paths
- Can set different weights (400=regular, 700=bold)

## 🎨 Common Use Cases

### Adding a Package

1. Find package on [pub.dev](https://pub.dev)
2. Add to `dependencies:`
```yaml
dependencies:
  google_fonts: ^6.1.0
```
3. Run `flutter pub get` in terminal
4. Import in your Dart file:
```dart
import 'package:google_fonts/google_fonts.dart';
```

### Adding Images

1. Create `assets/images/` folder in your project
2. Add images to the folder
3. Declare in `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/images/
```
4. Use in code:
```dart
Image.asset('assets/images/logo.png')
```

### Adding Custom Fonts

1. Create `fonts/` folder and add `.ttf` files
2. Declare in `pubspec.yaml`:
```yaml
flutter:
  fonts:
    - family: CustomFont
      fonts:
        - asset: fonts/CustomFont-Regular.ttf
```
3. Use in code:
```dart
Text('Hello', style: TextStyle(fontFamily: 'CustomFont'))
```

## ⚠️ Common Mistakes

1. **Indentation errors**: YAML is sensitive to spaces
   ```yaml
   # ❌ Wrong
   flutter:
   assets:
     - assets/images/
   
   # ✅ Correct
   flutter:
     assets:
       - assets/images/
   ```

2. **Forgetting `flutter pub get`**: Always run after changing dependencies

3. **Wrong path separators**: Always use `/` not `\`
   ```yaml
   # ❌ Wrong
   - assets\images\logo.png
   
   # ✅ Correct
   - assets/images/logo.png
   ```

## 🚀 Essential Commands

```bash
# Install/update dependencies
flutter pub get

# Update packages to latest compatible versions
flutter pub upgrade

# Remove unused dependencies
flutter pub deps

# Clear package cache
flutter pub cache clean
```

## 💡 Pro Tips

1. **Declare folders, not individual files** for assets:
   ```yaml
   assets:
     - assets/images/  # All files in this folder
   ```

2. **Use version constraints** to avoid breaking changes:
   ```yaml
   dependencies:
     package_name: ^1.0.0  # Safe updates
   ```

3. **Keep it organized**: Group related dependencies together

4. **Check pub.dev** for package documentation and examples

5. **Commit `pubspec.lock`** to ensure consistent builds across team

## ✅ Quick Checklist

- [ ] Correct indentation (2 or 4 spaces consistently)
- [ ] Run `flutter pub get` after changes
- [ ] Declare all assets being used
- [ ] Use meaningful package versions
- [ ] Test after adding new dependencies

---

**Previous:** [Flutter Project Structure](./01-flutter-project-structure.md)  
**Next:** [The lib Folder and main.dart](./03-lib-folder-and-main-dart.md)
