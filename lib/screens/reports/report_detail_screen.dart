import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/report_model.dart';
import '../../database/database_helper.dart';
import '../../utils/constants.dart';

class ReportDetailScreen extends StatefulWidget {
  final ReportModel report;

  const ReportDetailScreen({
    super.key,
    required this.report,
  });

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  late ReportModel _report;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _report = widget.report;
  }

  Future<void> _deleteReport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: Text('Are you sure you want to delete "${_report.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isDeleting = true);

      try {
        // Delete from local database
        if (_report.id != null) {
          await DatabaseHelper.instance.deleteReport(_report.id!);
        }

        // Try to delete from Supabase if online
        final connectivityResult = await Connectivity().checkConnectivity();
        final hasInternet = !connectivityResult.contains(ConnectivityResult.none);
        
        if (hasInternet && _report.id != null) {
          await Supabase.instance.client
              .from(AppConstants.reportsTable)
              .delete()
              .eq('id', _report.id!);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting report: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isDeleting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        actions: [
          if (_isDeleting)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteReport();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete Report'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(_report.category ?? 'Other').withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _report.category ?? 'Other',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _getCategoryColor(_report.category ?? 'Other'),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              _report.isSynced ? Icons.cloud_done : Icons.cloud_off,
                              size: 20,
                              color: _report.isSynced ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _report.isSynced ? 'Synced' : 'Local only',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: _report.isSynced ? Colors.green : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      _report.title,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    if (_report.amount != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'TSh ${_report.amount!.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Details Section
            Text(
              'Details',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            
            const SizedBox(height: 12),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow(
                      'Date',
                      _report.date != null
                          ? _formatDate(_report.date!)
                          : _report.createdAt != null
                              ? _formatDate(_report.createdAt!)
                              : 'Unknown',
                      Icons.calendar_today,
                    ),
                    
                    const Divider(),
                    
                    _buildDetailRow(
                      'Category',
                      _report.category ?? 'Other',
                      _getCategoryIcon(_report.category ?? 'Other'),
                    ),
                    
                    if (_report.amount != null) ...[
                      const Divider(),
                      _buildDetailRow(
                        'Amount',
                        'TSh ${_report.amount!.toStringAsFixed(2)}',
                        Icons.attach_money,
                      ),
                    ],
                    
                    if (_report.createdAt != null) ...[
                      const Divider(),
                      _buildDetailRow(
                        'Created',
                        _formatDateTime(_report.createdAt!),
                        Icons.access_time,
                      ),
                    ],
                    
                    if (_report.updatedAt != null && 
                        _report.updatedAt != _report.createdAt) ...[
                      const Divider(),
                      _buildDetailRow(
                        'Updated',
                        _formatDateTime(_report.updatedAt!),
                        Icons.update,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            if (_report.description != null && _report.description!.isNotEmpty) ...[
              const SizedBox(height: 20),
              
              Text(
                'Description',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              
              const SizedBox(height: 12),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _report.description!,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color(0xFF374151),
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6B7280)),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${_formatTime(dateTime)}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
} 