import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/constants.dart';
import '../../main.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: AppConstants.companyEmail,
      query: 'subject=SmartBiz Support Request',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch email';
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: AppConstants.companyPhone,
    );
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch phone';
    }
  }

  Future<void> _launchWhatsApp() async {
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/${AppConstants.companyPhone.replaceAll('+', '').replaceAll('-', '')}?text=Hello, I need help with SmartBiz app',
    );
    
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
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
                    'We\'re here to help!',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get in touch with our support team',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Contact Methods
            Text(
              'Contact Methods',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Email Card
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.email_outlined,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                title: Text(
                  'Email Support',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  AppConstants.companyEmail,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  try {
                    await _launchEmail();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not launch email: $e')),
                      );
                    }
                  }
                },
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Phone Card
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.phone_outlined,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                title: Text(
                  'Phone Support',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  AppConstants.companyPhone,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  try {
                    await _launchPhone();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not launch phone: $e')),
                      );
                    }
                  }
                },
              ),
            ),
            
            const SizedBox(height: 12),
            
            // WhatsApp Card
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chat_outlined,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                title: Text(
                  'WhatsApp Support',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Chat with us on WhatsApp',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  try {
                    await _launchWhatsApp();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not launch WhatsApp: $e')),
                      );
                    }
                  }
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Business Hours
            Text(
              'Business Hours',
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
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Support Hours',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildBusinessHour('Monday - Friday', '9:00 AM - 6:00 PM'),
                    _buildBusinessHour('Saturday', '10:00 AM - 4:00 PM'),
                    _buildBusinessHour('Sunday', 'Closed'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'For urgent issues outside business hours, please email us and we\'ll respond within 24 hours.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // App Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Information',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Version',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          AppConstants.appVersion,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'App Name',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          AppConstants.appName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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

  Widget _buildBusinessHour(String day, String hours) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
          Text(
            hours,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 