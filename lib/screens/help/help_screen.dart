import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
import 'contact_screen.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  const SmartBizLogo(fontSize: 32),
                  const SizedBox(height: 16),
                  Text(
                    'How can we help you?',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Quick Help Options
            Text(
              'Quick Help',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Contact Support Card
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.support_agent,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                title: Text(
                  'Contact Support',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Get help from our support team',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ContactScreen()),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            // FAQ Section
            Text(
              'Frequently Asked Questions',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildFAQItem(
              'How do I create a new report?',
              'Navigate to the Reports section and tap the "+" button to create a new report. Fill in the required information and save.',
            ),
            
            _buildFAQItem(
              'How do I submit feedback?',
              'Go to the Feedback section, fill out the feedback form with your comments and rating, then submit.',
            ),
            
            _buildFAQItem(
              'How do I change my password?',
              'Go to Settings > Account > Change Password, enter your current password and new password.',
            ),
            
            _buildFAQItem(
              'How do I backup my data?',
              'Your data is automatically synced to the cloud when you have an internet connection. You can also enable auto-backup in Settings.',
            ),
            
            _buildFAQItem(
              'How do I use the app offline?',
              'SmartBiz works offline for viewing saved reports and data. New data will sync when you\'re back online.',
            ),
            
            const SizedBox(height: 32),
            
            // Getting Started
            Text(
              'Getting Started',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New to SmartBiz?',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Follow these steps to get started:',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStep('1', 'Complete your profile in the Account section'),
                    _buildStep('2', 'Explore the Dashboard to see available features'),
                    _buildStep('3', 'Create your first report in the Reports section'),
                    _buildStep('4', 'Customize your settings for the best experience'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          question,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 