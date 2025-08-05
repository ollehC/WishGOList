# 🛍️ WishGO List - Flutter Shopping Wishlist App

<div align="center">
  <img src="https://via.placeholder.com/200x200/6B73FF/FFFFFF?text=WishGO" alt="WishGO List Logo" width="120" height="120">
  
  **Your Ultimate Cross-Platform Shopping Wishlist Companion**
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue.svg)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
  [![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey.svg)](https://flutter.dev/)
</div>

## 📱 About WishGO List

WishGO List is a comprehensive cross-platform shopping wishlist application built with Flutter. It helps users manage items they want to buy with intelligent URL processing, Pinterest-style visual layouts, and powerful organization features.

### ✨ Key Features

#### 🆓 **Free Tier**
- 🔗 Add items via URL with automatic OpenGraph metadata extraction
- ✏️ Manual item editing (name, price, notes, images)
- 📊 Status tracking: To Buy / Purchased / Dropped
- 🏷️ Tagging system (up to 5 tags)
- 🎨 Pinterest-style card/grid view
- 💾 Local storage with no login required
- 📁 1 collection folder
- 📦 Manual order tracking (up to 2 entries)

#### 💎 **Premium Features**
- 📈 Price tracking with drop alerts
- 🏷️ Unlimited tags and custom collections
- 🎨 Custom themes and dark mode
- 📤 Export to CSV, PDF, Google Sheets
- ☁️ Firebase cloud sync and backup
- ❤️ Desire level rating system (1-5 hearts)
- ⚡ Batch operations and advanced filtering
- 📦 Unlimited order tracking with carrier integration
- 📊 Shopping analytics and spending insights

## 🏗️ Architecture

### **Technology Stack**
- **Framework**: Flutter 3.10+ with Material 3 design
- **Language**: Dart 3.0+
- **State Management**: Provider pattern
- **Local Database**: SQLite with relationship mapping
- **Cloud Database**: Firebase Firestore (Premium)
- **Authentication**: Firebase Auth (Premium)
- **Payments**: In-App Purchases (iOS/Android)

### **Project Structure**
```
lib/
├── main.dart                           # App entry point
└── src/main/flutter/
    ├── core/                          # Core application logic
    │   ├── app.dart                   # Main app configuration
    │   ├── database/                  # SQLite database layer
    │   ├── providers/                 # State management
    │   ├── routing/                   # Navigation system
    │   └── services/                  # Business logic services
    ├── models/                        # Data models
    ├── screens/                       # UI screens
    ├── widgets/                       # Reusable UI components
    ├── ui/theme/                      # Theme and styling
    └── utils/                         # Utility functions
```

### **Key Components**

#### **Data Models**
- `WishItem`: Core shopping item with metadata
- `Collection`: Organization containers
- `Order`: Purchase tracking
- `Tag`: Categorization system
- `UserPreferences`: App settings and premium status

#### **Services**
- `DatabaseService`: SQLite CRUD operations
- `OpenGraphService`: URL metadata extraction
- `StorageService`: Local preferences
- `ApiService`: HTTP client with retry logic

#### **Providers**
- `WishItemProvider`: Item management and filtering
- `CollectionProvider`: Organization system
- `UserPreferencesProvider`: Settings and premium features
- `SubscriptionProvider`: Premium tier management

## 🚀 Getting Started

### **Prerequisites**
- Flutter SDK 3.10 or higher
- Dart SDK 3.0 or higher
- iOS development: Xcode 14+
- Android development: Android Studio with SDK 21+

### **Installation**

1. **Clone the repository**
   ```bash
   git clone https://github.com/ollehC/WishGOList.git
   cd WishGOList
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # iOS Simulator
   flutter run -d ios
   
   # Android Emulator
   flutter run -d android
   
   # All connected devices
   flutter run
   ```

### **Build for Production**

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 📦 Dependencies

### **Core Dependencies**
- `provider`: State management
- `sqflite`: Local database
- `shared_preferences`: Local storage
- `http` & `dio`: Network requests
- `metadata_fetch`: URL metadata extraction

### **UI Dependencies**
- `flutter_staggered_grid_view`: Pinterest-style layouts
- `cached_network_image`: Image caching
- `image_picker`: Photo selection
- `fl_chart`: Analytics charts

### **Premium Features**
- `firebase_core`: Firebase integration
- `cloud_firestore`: Cloud database
- `firebase_auth`: User authentication
- `in_app_purchase`: Subscription management

## 🎨 Design System

### **Color Palette**
- **Primary**: #6B73FF (Modern purple-blue)
- **Secondary**: #FF6B9D (Pink accent)
- **Success**: #4CAF50 (Green)
- **Premium**: #FFD700 (Gold)

### **Typography**
- System fonts with proper scaling
- Material 3 typography scale
- Accessibility-compliant contrast ratios

### **Layout Principles**
- Pinterest-style masonry grids
- Material 3 design language
- Responsive layouts for all screen sizes
- Dark mode support

## 💰 Monetization Strategy

### **Subscription Tiers**
- **Monthly**: HKD $15–25
- **Yearly**: HKD $168–228 (30% discount)
- **Lifetime**: HKD $328–398

### **Premium Value Proposition**
- Unlimited items and collections
- Advanced analytics and insights
- Cloud sync and backup
- Export capabilities
- Price tracking and alerts
- Custom themes and personalization

## 🛠️ Development Guidelines

### **Code Style**
- Follow Dart style guide
- Use `flutter analyze` for linting
- Maintain consistent file structure
- Document public APIs

### **Git Workflow**
- Feature branches for new development
- Descriptive commit messages
- Regular pushes to maintain backup

### **Testing Strategy**
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for user flows
- Minimum 80% code coverage goal

## 🔧 Configuration

### **Environment Setup**
- Development, staging, and production environments
- Firebase configuration per environment
- API endpoint configuration
- Feature flags for premium features

### **Platform-Specific Configuration**
- iOS: Info.plist permissions
- Android: Manifest permissions and proguard rules
- App signing configuration for releases

## 📈 Analytics and Monitoring

### **Implemented Tracking**
- User engagement metrics
- Feature usage analytics
- Crash reporting and error monitoring
- Performance monitoring
- Subscription conversion tracking

## 🚢 Deployment

### **App Store Requirements**
- iOS: App Store Connect configuration
- Android: Google Play Console setup
- Screenshots and marketing materials
- Privacy policy and terms of service

### **Release Process**
1. Version bump and changelog
2. Build and test release candidates
3. Submit to app stores
4. Monitor deployment metrics

## 🤝 Contributing

This project was developed as a comprehensive Flutter application demonstrating modern mobile app development practices with premium monetization features.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Template by Chang Ho Chien | HC AI 說人話channel
- Tutorial Video: https://youtu.be/8Q1bRZaHH24
- Generated with Claude Code (claude.ai/code)

---

<div align="center">
  <p><strong>Built with ❤️ using Flutter</strong></p>
  <p>Ready for production deployment on iOS and Android</p>
</div>