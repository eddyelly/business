import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.email ?? 'No email',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Account Actions
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Edit Profile'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Implement edit profile
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.security_outlined),
              title: const Text('Change Password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Implement change password
              },
            ),
            
            const Spacer(),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  await AuthService.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text(
                  'Logout',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 