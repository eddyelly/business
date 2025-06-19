# SmartBiz - Business Management Mobile App

<div align="center">
  <h3>📱 A Flutter-based business management application for Android</h3>
  <p><em>Business Made Simple</em></p>
</div>

## 🚀 Features

### 🔐 **Authentication System**
- User registration and login
- Secure authentication with Supabase
- Password validation and error handling
- Automatic session management

### 📊 **Reports Management**
- Create detailed business reports with categories
- View and filter reports by category (Sales, Expenses, Revenue, Inventory, Marketing)
- Analytics dashboard with visual breakdowns
- Offline-first with cloud synchronization
- Export and share capabilities

### 💬 **Feedback System**
- Submit structured feedback with categories and ratings
- View feedback history
- Rate different aspects of the business
- Local storage with cloud backup

### 🎯 **Dashboard**
- Clean, intuitive home screen
- Quick access to all features
- User profile management
- Real-time connectivity status

### 📞 **Help & Support**
- Comprehensive FAQ section
- Direct contact options (Phone, Email, WhatsApp)
- Getting started guide
- Business hours and contact information

### ⚙️ **Settings & Profile**
- User account management
- App preferences
- Theme customization options
- Notification settings

## 🛠️ **Technical Stack**

### **Frontend**
- **Flutter** - Cross-platform mobile development
- **Material Design 3** - Modern UI components
- **Google Fonts** - Typography (Poppins)
- **Animations** - Smooth user experience

### **Backend & Database**
- **Supabase** - Backend-as-a-Service
  - Authentication
  - PostgreSQL database
  - Real-time subscriptions
  - Row Level Security (RLS)
- **SQLite** - Local database for offline functionality
- **SharedPreferences** - Local settings storage

### **Key Packages**
```yaml
dependencies:
  flutter: ^3.24.5
  supabase_flutter: ^2.8.0
  sqflite: ^2.4.1
  connectivity_plus: ^6.1.0
  url_launcher: ^6.3.1
  google_fonts: ^6.2.1
  shared_preferences: ^2.3.3
  flutter_hooks: ^0.20.5
  animations: ^2.0.11
```

## 📱 **Screenshots**

*Screenshots will be added here*

## 🏗️ **Architecture**

### **Project Structure**
```
lib/
├── main.dart                 # App entry point
├── database/
│   └── database_helper.dart  # SQLite database management
├── models/
│   ├── feedback_model.dart   # Feedback data model
│   ├── report_model.dart     # Report data model
│   └── user_preferences_model.dart
├── screens/
│   ├── auth/                 # Authentication screens
│   ├── home/                 # Dashboard
│   ├── reports/              # Reports management
│   ├── feedback/             # Feedback system
│   ├── help/                 # Help and support
│   ├── profile/              # User profile
│   └── settings/             # App settings
├── services/
│   └── auth_service.dart     # Authentication logic
├── utils/
│   └── constants.dart        # App constants
└── widgets/                  # Reusable UI components
```

### **Database Schema**

#### **Supabase Tables**
```sql
-- Users (handled by Supabase Auth)
-- Feedback table
CREATE TABLE feedback (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  category TEXT NOT NULL,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  message TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Reports table
CREATE TABLE reports (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  title TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL,
  amount DECIMAL(10,2),
  date DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 🚀 **Getting Started**

### **Prerequisites**
- Flutter SDK (3.24.5 or higher)
- Dart SDK (3.5.4 or higher)
- Android Studio / VS Code
- Android device or emulator

### **Installation**

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/smartbiz.git
   cd smartbiz
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Supabase**
   - Create a Supabase project at [supabase.com](https://supabase.com)
   - Copy your project URL and anon key
   - Update `lib/utils/constants.dart` with your credentials
   - Run the SQL setup script: `supabase_setup.sql`

4. **Run the app**
   ```bash
   flutter run
   ```

### **Environment Variables (Optional)**
For production deployment, you can use environment variables:

```bash
flutter run --dart-define=SUPABASE_URL=your_supabase_url \
           --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

## 📋 **Features Roadmap**

### ✅ **Completed**
- [x] User Authentication
- [x] Reports CRUD operations
- [x] Feedback system
- [x] Offline functionality
- [x] Dashboard with analytics
- [x] Help and support pages
- [x] Material Design 3 UI

### 🔄 **In Progress**
- [ ] Settings screen completion
- [ ] Data export functionality
- [ ] Advanced analytics charts

### 📅 **Planned**
- [ ] Push notifications
- [ ] Dark theme
- [ ] Multi-language support
- [ ] Advanced reporting features
- [ ] Data visualization improvements

## 🧪 **Testing**

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

## 📦 **Building for Release**

### **Android APK**
```bash
flutter build apk --release
```

### **Android App Bundle**
```bash
flutter build appbundle --release
```

## 🤝 **Contributing**

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 **Author**

**Edward** - *Flutter Developer*

## 📞 **Support**

For support, email support@smartbiz.com or contact us through the app.

## 🙏 **Acknowledgments**

- Flutter team for the amazing framework
- Supabase for the backend infrastructure
- Material Design team for the design system
- Google Fonts for typography

---

<div align="center">
  <p>Made with ❤️ using Flutter</p>
  <p><em>SmartBiz - Business Made Simple</em></p>
</div>
