# Trackify 

A Flutter habit-tracking application built as a learning project during the 100 Days of Code challenge. Trackify helps users build and maintain positive habits by providing a clean, intuitive interface to track daily habit completion.

## 📱 Features

- **Habit Dashboard** - View all your habits in one beautiful dashboard
- **Add/Edit/Delete Habits** - Full CRUD operations for managing your habits
- **Completion Tracking** - Toggle habit completion status with a single tap
- **Local Storage** - Habits are automatically saved to your device using SharedPreferences
- **Theme Customization** - Support for custom themes with JSON configuration
- **User Profile** - Track user information and settings
- **Responsive Design** - Built with Material Design for a clean, modern UI
- **State Management** - Uses Provider for efficient state management across the app

## 🏗️ Architecture

Trackify follows a clean architecture pattern with clear separation of concerns:

### State Management
- **Provider** (`provider: ^6.1.5+1`) - Used for reactive state management
  - `HabitProvider` - Manages habit CRUD operations and notifications
  - `ThemeProvider` - Handles theme switching and customization

### Data Persistence
- **SharedPreferences** (`shared_preferences: ^2.5.5`) - Local device storage for habits
- **UUID** (`uuid: ^4.5.3`) - Generates unique identifiers for habits

### Key Components

#### Models (`lib/models/`)
- `Habit` - Core habit model with serialization/deserialization
  - Properties: `id`, `name`, `completed`
  - Methods: `toMap()`, `fromJson()` for storage

- `UserProfile` - User information and preferences

#### Providers (`lib/providers/`)
- `HabitProvider` - Handles all habit operations
  - Create habits with auto-generated UUIDs
  - Toggle habit completion status
  - Edit habit names
  - Delete habits
  - Automatic persistence to SharedPreferences

- `ThemeProvider` - Manages app theming

#### Screens (`lib/screens/`)
- `DashboardScreen` - Main habit list and overview
- `HabitDetailScreen` - Individual habit details and management
- `ProfileScreen` - User profile information
- `SettingsScreen` - App configuration and preferences

#### Widgets (`lib/widgets/`)
- `HabitCard` - Reusable habit display component

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (version 3.8.1 or higher)
- Dart SDK (comes with Flutter)
- A connected device or emulator

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd test_100days
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Web Development

For web-specific development and testing:

#### Local Development Server
```bash
# Run on Chrome with custom port
flutter run -d chrome --web-port=8080

# Run on default browser
flutter run -d web-server

# Run on specific browser
flutter run -d edge
flutter run -d safari
```

#### Web Build and Serve
```bash
# Build for web
flutter build web

# Serve locally (requires web server)
cd build/web && python3 -m http.server 8000
# Or use any static file server
```

### Building

For production builds:

```bash
# Android
flutter build apk

# iOS
flutter build ios

# Web
flutter build web

# Linux
flutter build linux

# Windows
flutter build windows
```

## 📂 Project Structure

```
lib/
├── main.dart                 # App entry point with MultiProvider setup
├── models/
│   ├── habit.dart           # Habit model with JSON serialization
│   └── user_profile.dart    # User profile model
├── providers/
│   ├── habit_provider.dart  # Habit state management and persistence
│   └── theme_provider.dart  # Theme state management
├── screens/
│   ├── dashboard_screen.dart    # Main habit dashboard
│   ├── habit_detail_screen.dart # Individual habit details
│   ├── profile_screen.dart      # User profile
│   └── settings_screen.dart     # App settings
└── widgets/
    └── habit_card.dart      # Reusable habit card component

assets/
├── custom_theme.json        # Custom theme configuration
└── fonts/                   # Custom fonts (if any)
```

## 🔄 How It Works

### Adding a Habit
1. Navigate to the dashboard
2. Use the add button to create a new habit
3. The habit is automatically saved to local storage

### Toggling Completion
1. Tap on any habit card
2. The completion status toggles automatically
3. Changes are persisted to SharedPreferences

### Editing or Deleting
- Tap and hold (or use the menu) to edit or delete habits
- All changes are automatically saved

## 📦 Dependencies

- **flutter** - Core Flutter framework
- **provider** (v6.1.5+1) - State management and reactive data flow
- **shared_preferences** (v2.5.5) - Local key-value storage
- **uuid** (v4.5.3) - Unique ID generation
- **flutter_lints** (v6.0.0) - Code quality linting

## 🎨 Customization

### Theme
The app supports custom themes via `assets/custom_theme.json`. Modify this file to change:
- Color schemes
- Text styles
- Component styling

## 🧪 Testing

Run tests with:
```bash
flutter test
```

## 💡 Learning Highlights

This project demonstrates:
- ✅ Provider pattern for state management
- ✅ Local data persistence with SharedPreferences
- ✅ Model serialization/deserialization
- ✅ Custom widgets and reusable components
- ✅ Multi-screen navigation
- ✅ Material Design principles
- ✅ Null safety in Dart
- ✅ CRUD operations in Flutter

## 📝 Future Enhancements

- [ ] Habit statistics and progress charts
- [ ] Daily reminders and notifications
- [ ] Habit categories/tags
- [ ] Streak tracking
- [ ] Cloud sync across devices
- [ ] Dark mode theme toggle
- [ ] Habit completion history
- [ ] Export habit data

## 👤 About

This is a learning project created by **@North-Abyss** as part of the 100 Days of Code challenge to master Flutter development fundamentals.

## 📄 License

This project is open source and available under the MIT License.

---

**Happy tracking! 🚀**
