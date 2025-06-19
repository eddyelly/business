import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  
  runApp(const SmartBizApp());
}

class SmartBizApp extends StatelessWidget {
  const SmartBizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartBiz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB), // Professional blue
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// SmartBiz Logo Widget
class SmartBizLogo extends StatelessWidget {
  final double fontSize;
  final Color? color;
  final bool showTagline;

  const SmartBizLogo({
    super.key,
    this.fontSize = 32,
    this.color= Colors.white,
    this.showTagline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Smart',
                style: GoogleFonts.poppins(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: color ?? const Color(0xFF2563EB),
                ),
              ),
              TextSpan(
                text: 'Biz',
                style: GoogleFonts.poppins(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: color ?? const Color(0xFF1D4ED8),
                ),
              ),
            ],
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 8),
          Text(
            'Business Made Simple',
            style: GoogleFonts.poppins(
              fontSize: fontSize * 0.35,
              fontWeight: FontWeight.w500,
              color: (color ?? const Color(0xFF6B7280)).withOpacity(0.8),
            ),
          ),
        ],
      ],
    );
  }
}
