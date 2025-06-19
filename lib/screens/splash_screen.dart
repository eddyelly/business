import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../database/database_helper.dart';
import 'auth/login_screen.dart';
import 'home/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize local database
      await DatabaseHelper.instance.database;
      
      // Check internet connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasInternet = !connectivityResult.contains(ConnectivityResult.none);
      
      // Wait for animation to complete
      await Future.delayed(const Duration(milliseconds: 3000));
      
      if (mounted) {
        if (hasInternet) {
          await _checkAuthAndNavigate();
        } else {
          _showNoInternetDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Initialization failed: ${e.toString()}');
      }
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      
      if (mounted) {
        if (session != null) {
          // User is logged in, go to dashboard
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        } else {
          // User is not logged in, go to login
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // If there's an error, go to login screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text(
          'SmartBiz requires an internet connection to function properly. Please check your connection and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeApp();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SmartBizLogo(
                      fontSize: 48,
                      showTagline: true,
                    ),
                    const SizedBox(height: 40),
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Initializing SmartBiz...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
} 