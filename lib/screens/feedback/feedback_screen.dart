import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/feedback_model.dart';
import '../../database/database_helper.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
  controller: _tabController,
  labelColor: Colors.white,
  unselectedLabelColor: Colors.white70, // Optional: makes inactive tab text slightly dimmer
  tabs: const [
    Tab(
      text: 'Submit Feedback',
      icon: Icon(Icons.add_comment, color: Colors.white),
    ),
    Tab(
      text: 'My Feedback',
      icon: Icon(Icons.history, color: Colors.white),
    ),
  ],
),

      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SubmitFeedbackTab(),
          ViewFeedbackTab(),
        ],
      ),
    );
  }
}

class SubmitFeedbackTab extends StatefulWidget {
  const SubmitFeedbackTab({super.key});

  @override
  State<SubmitFeedbackTab> createState() => _SubmitFeedbackTabState();
}

class _SubmitFeedbackTabState extends State<SubmitFeedbackTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCategory = 'General';
  int _rating = 5;
  bool _isSubmitting = false;
  
  final List<String> _categories = [
    'General',
    'Bug Report',
    'Feature Request',
    'User Interface',
    'Performance',
    'Other'
  ];

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = AuthService.currentUser;
      final feedback = FeedbackModel(
        userId: user?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        rating: _rating,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to local database first
      final localId = await DatabaseHelper.instance.insertFeedback(feedback);
      
      // Try to sync with Supabase
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasInternet = !connectivityResult.contains(ConnectivityResult.none);
      
      if (hasInternet) {
        try {
          await Supabase.instance.client
              .from(AppConstants.feedbackTable)
              .insert(feedback.toJson());
          
          // Mark as synced if successful
          await DatabaseHelper.instance.markFeedbackAsSynced(localId);
          
          if (mounted) {
            _showMessage('Feedback submitted successfully!', isSuccess: true);
          }
        } catch (e) {
          if (mounted) {
            _showMessage('Feedback saved locally. Will sync when online.', isSuccess: true);
          }
        }
      } else {
        if (mounted) {
          _showMessage('Feedback saved locally. Will sync when online.', isSuccess: true);
        }
      }
      
      // Clear form
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedCategory = 'General';
        _rating = 5;
      });
      
    } catch (e) {
      if (mounted) {
        _showMessage('Failed to submit feedback: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMessage(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'We value your feedback',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Help us improve SmartBiz by sharing your thoughts and suggestions.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: const Color(0xFF6B7280),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Category Selection
            Text(
              'Category',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF9FAFB),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Title Field
            Text(
              'Title',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            
            const SizedBox(height: 8),
            
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Brief title for your feedback',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                if (value.trim().length < 5) {
                  return 'Title must be at least 5 characters';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            // Description Field
            Text(
              'Description',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            
            const SizedBox(height: 8),
            
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Describe your feedback in detail...',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                if (value.trim().length < 10) {
                  return 'Description must be at least 10 characters';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            // Rating
            Text(
              'Overall Rating',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                        );
                      }),
                    ),
                    Text(
                      _getRatingText(_rating),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Submit Feedback',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}

class ViewFeedbackTab extends StatefulWidget {
  const ViewFeedbackTab({super.key});

  @override
  State<ViewFeedbackTab> createState() => _ViewFeedbackTabState();
}

class _ViewFeedbackTabState extends State<ViewFeedbackTab> {
  List<FeedbackModel> _feedbackList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  Future<void> _loadFeedback() async {
    try {
      final feedback = await DatabaseHelper.instance.getAllFeedback();
      setState(() {
        _feedbackList = feedback;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_feedbackList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.feedback_outlined,
              size: 64,
              color: Color(0xFF6B7280),
            ),
            const SizedBox(height: 16),
            Text(
              'No feedback yet',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your submitted feedback will appear here',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFeedback,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _feedbackList.length,
        itemBuilder: (context, index) {
          final feedback = _feedbackList[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(feedback.category ?? 'General').withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          feedback.category ?? 'General',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getCategoryColor(feedback.category ?? 'General'),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            feedback.isSynced ? Icons.cloud_done : Icons.cloud_off,
                            size: 16,
                            color: feedback.isSynced ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            feedback.isSynced ? 'Synced' : 'Local',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: feedback.isSynced ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    feedback.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    feedback.description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(5, (starIndex) {
                          return Icon(
                            starIndex < (feedback.rating ?? 0) ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                      ),
                      Text(
                        feedback.createdAt != null
                            ? _formatDate(feedback.createdAt!)
                            : 'Unknown date',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Bug Report':
        return Colors.red;
      case 'Feature Request':
        return Colors.blue;
      case 'User Interface':
        return Colors.purple;
      case 'Performance':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 