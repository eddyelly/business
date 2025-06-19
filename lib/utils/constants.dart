class AppConstants {
  // Supabase Configuration
  // Note: These are public anon keys safe for client-side use
  // For production, consider using environment variables
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://zwryvimigxwxybzvxotl.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp3cnl2aW1pZ3h3eHlienZ4b3RsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAzNjI4OTYsImV4cCI6MjA2NTkzODg5Nn0.SIqSp2yHKLrAA_LfNhl4KhBsXTOHu2ZP7zrD-yMb6Yk',
  );
  
  // Database Tables
  static const String feedbackTable = 'feedback';
  static const String reportsTable = 'reports';
  static const String usersTable = 'users';
  
  // App Information
  static const String appName = 'SmartBiz';
  static const String appVersion = '1.0.0';
  static const String companyEmail = 'support@smartbiz.com';
  static const String companyPhone = '+255766615858';
  
  // SharedPreferences Keys
  static const String keyFirstLaunch = 'first_launch';
  static const String keyThemeMode = 'theme_mode';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyUserPreferences = 'user_preferences';
  
  // SQLite Database
  static const String localDbName = 'smartbiz_local.db';
  static const int localDbVersion = 1;
} 