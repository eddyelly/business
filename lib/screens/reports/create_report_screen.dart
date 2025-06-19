import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/report_model.dart';
import '../../database/database_helper.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  
  String _selectedCategory = 'Sales';
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;
  
  final List<String> _categories = [
    'Sales',
    'Expenses',
    'Revenue',
    'Inventory',
    'Marketing',
    'Other'
  ];

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = AuthService.currentUser;
      final report = ReportModel(
        userId: user?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        amount: double.tryParse(_amountController.text.trim()),
        category: _selectedCategory,
        date: _selectedDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to local database first
      final localId = await DatabaseHelper.instance.insertReport(report);
      
      // Try to sync with Supabase
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasInternet = !connectivityResult.contains(ConnectivityResult.none);
      
      if (hasInternet) {
        try {
          await Supabase.instance.client
              .from(AppConstants.reportsTable)
              .insert(report.toJson());
          
          // Mark as synced if successful
          await DatabaseHelper.instance.markReportAsSynced(localId);
          
          if (mounted) {
            _showMessage('Report created successfully!', isSuccess: true);
          }
        } catch (e) {
          if (mounted) {
            _showMessage('Report saved locally. Will sync when online.', isSuccess: true);
          }
        }
      } else {
        if (mounted) {
          _showMessage('Report saved locally. Will sync when online.', isSuccess: true);
        }
      }
      
      // Return to previous screen
      if (mounted) {
        Navigator.of(context).pop(true);
      }
      
    } catch (e) {
      if (mounted) {
        _showMessage('Failed to create report: ${e.toString()}');
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
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Report'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submitReport,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Create Business Report',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Add details about your business transaction or report.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFF6B7280),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title Field
              Text(
                'Report Title *',
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
                  hintText: 'Enter report title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  if (value.trim().length < 3) {
                    return 'Title must be at least 3 characters';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Category Selection
              Text(
                'Category *',
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
                        child: Row(
                          children: [
                            Icon(
                              _getCategoryIcon(category),
                              size: 20,
                              color: _getCategoryColor(category),
                            ),
                            const SizedBox(width: 8),
                            Text(category),
                          ],
                        ),
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
              
              // Amount Field
              Text(
                'Amount (TSh)',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              
              const SizedBox(height: 8),
              
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: 'Enter amount (optional)',
                  prefixIcon: Icon(Icons.attach_money),
                  prefixText: 'TSh ',
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final amount = double.tryParse(value.trim());
                    if (amount == null) {
                      return 'Please enter a valid amount';
                    }
                    if (amount < 0) {
                      return 'Amount cannot be negative';
                    }
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Date Selection
              Text(
                'Date *',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              
              const SizedBox(height: 8),
              
              InkWell(
                onTap: _selectDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF9FAFB),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
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
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Add additional details (optional)',
                  alignLabelWithHint: true,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Preview Card
              Text(
                'Preview',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(_selectedCategory).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _selectedCategory,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getCategoryColor(_selectedCategory),
                              ),
                            ),
                          ),
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Text(
                        _titleController.text.isEmpty ? 'Report Title' : _titleController.text,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      
                      if (_descriptionController.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          _descriptionController.text,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                      
                      if (_amountController.text.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'TSh ${_amountController.text}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Sales':
        return Icons.trending_up;
      case 'Expenses':
        return Icons.trending_down;
      case 'Revenue':
        return Icons.attach_money;
      case 'Inventory':
        return Icons.inventory;
      case 'Marketing':
        return Icons.campaign;
      default:
        return Icons.description;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Sales':
        return Colors.green;
      case 'Expenses':
        return Colors.red;
      case 'Revenue':
        return Colors.blue;
      case 'Inventory':
        return Colors.orange;
      case 'Marketing':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
} 