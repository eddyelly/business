import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../profile/account_screen.dart';
import '../reports/reports_screen.dart';
import '../feedback/feedback_screen.dart';
import '../settings/settings_screen.dart';
import '../help/help_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  
  late final List<Widget> _screens;
  late final List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();
    
    _screens = [
      const DashboardHome(),
      const ReportsScreen(),
      const FeedbackScreen(),
      const AccountScreen(),
    ];
    
    _navItems = const [
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.assessment_outlined),
        activeIcon: Icon(Icons.assessment),
        label: 'Reports',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.feedback_outlined),
        activeIcon: Icon(Icons.feedback),
        label: 'Feedback',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Account',
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: const Color(0xFF6B7280),
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
        ),
        items: _navItems,
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const SmartBizLogo(fontSize: 20),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const HelpScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? 'User',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ready to manage your business smarter?',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildQuickActionCard(
                  context,
                  'View Reports',
                  Icons.assessment,
                  Colors.blue,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ReportsScreen()),
                  ),
                ),
                _buildQuickActionCard(
                  context,
                  'Give Feedback',
                  Icons.feedback,
                  Colors.green,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const FeedbackScreen()),
                  ),
                ),
                _buildQuickActionCard(
                  context,
                  'Settings',
                  Icons.settings,
                  Colors.orange,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  ),
                ),
                _buildQuickActionCard(
                  context,
                  'Help & Support',
                  Icons.help,
                  Colors.purple,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const HelpScreen()),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Recent Activity (Placeholder)
            Text(
              'Recent Activity',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No recent activity',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start using SmartBiz features to see activity here',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 