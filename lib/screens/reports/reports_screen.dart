import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/report_model.dart';
import '../../database/database_helper.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import 'create_report_screen.dart';
import 'report_detail_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
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
        title: const Text('Reports'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
  controller: _tabController,
  labelColor: Colors.white, // selected tab text/icon
  unselectedLabelColor: Colors.white70, // optional: unselected tab text/icon
  tabs: const [
    Tab(
      text: 'All Reports',
      icon: Icon(Icons.list_alt, color: Colors.white),
    ),
    Tab(
      text: 'Analytics',
      icon: Icon(Icons.analytics, color: Colors.white),
    ),
  ],
),

        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CreateReportScreen()),
              );
              if (result == true) {
                // Refresh the reports list
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ViewReportsTab(),
          AnalyticsTab(),
        ],
      ),
    );
  }
}

class ViewReportsTab extends StatefulWidget {
  const ViewReportsTab({super.key});

  @override
  State<ViewReportsTab> createState() => _ViewReportsTabState();
}

class _ViewReportsTabState extends State<ViewReportsTab> {
  List<ReportModel> _reports = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  
  final List<String> _categories = [
    'All',
    'Sales',
    'Expenses',
    'Revenue',
    'Inventory',
    'Marketing',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      setState(() => _isLoading = true);
      
      // Load from local database first
      final localReports = await DatabaseHelper.instance.getAllReports();
      
      // Try to sync with Supabase if online
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasInternet = !connectivityResult.contains(ConnectivityResult.none);
      
      if (hasInternet) {
        try {
          final user = AuthService.currentUser;
          if (user != null) {
            final response = await Supabase.instance.client
                .from(AppConstants.reportsTable)
                .select()
                .eq('user_id', user.id)
                .order('created_at', ascending: false);
            
            final cloudReports = (response as List)
                .map((json) => ReportModel.fromJson(json))
                .toList();
            
            // Merge local and cloud reports, prioritizing cloud data
            final Map<String, ReportModel> reportMap = {};
            
            // Add local reports first
            for (final report in localReports) {
              if (report.id != null) {
                reportMap[report.id.toString()] = report;
              }
            }
            
            // Override with cloud reports
            for (final report in cloudReports) {
              if (report.id != null) {
                reportMap[report.id.toString()] = report;
              }
            }
            
            setState(() {
              _reports = reportMap.values.toList()
                ..sort((a, b) => (b.createdAt ?? DateTime.now())
                    .compareTo(a.createdAt ?? DateTime.now()));
              _isLoading = false;
            });
            return;
          }
        } catch (e) {
          print('Error syncing reports: $e');
        }
      }
      
      // Fallback to local reports only
      setState(() {
        _reports = localReports;
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reports: $e')),
        );
      }
    }
  }

  List<ReportModel> get _filteredReports {
    if (_selectedCategory == 'All') {
      return _reports;
    }
    return _reports.where((report) => report.category == _selectedCategory).toList();
  }

  Future<void> _deleteReport(ReportModel report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: Text('Are you sure you want to delete "${report.title}"?'),
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
      try {
        // Delete from local database
        if (report.id != null) {
          await DatabaseHelper.instance.deleteReport(report.id!);
        }

        // Try to delete from Supabase if online
        final connectivityResult = await Connectivity().checkConnectivity();
        final hasInternet = !connectivityResult.contains(ConnectivityResult.none);
        
        if (hasInternet && report.id != null) {
          await Supabase.instance.client
              .from(AppConstants.reportsTable)
              .delete()
              .eq('id', report.id!);
        }

        await _loadReports();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting report: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category Filter
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Filter by:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
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
              ),
            ],
          ),
        ),
        
        // Reports List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredReports.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadReports,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredReports.length,
                        itemBuilder: (context, index) {
                          final report = _filteredReports[index];
                          return _buildReportCard(report);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.assessment_outlined,
            size: 64,
            color: Color(0xFF6B7280),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedCategory == 'All' ? 'No reports yet' : 'No $_selectedCategory reports',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedCategory == 'All'
                ? 'Create your first report to get started'
                : 'No reports found in this category',
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

  Widget _buildReportCard(ReportModel report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ReportDetailScreen(report: report),
            ),
          );
          if (result == true) {
            _loadReports();
          }
        },
        borderRadius: BorderRadius.circular(16),
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
                      color: _getCategoryColor(report.category ?? 'Other').withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report.category ?? 'Other',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getCategoryColor(report.category ?? 'Other'),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        report.isSynced ? Icons.cloud_done : Icons.cloud_off,
                        size: 16,
                        color: report.isSynced ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            _deleteReport(report);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                        child: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Text(
                report.title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              
              if (report.description != null && report.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  report.description!,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (report.amount != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'TSh ${report.amount!.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  Text(
                    report.date != null
                        ? _formatDate(report.date!)
                        : report.createdAt != null
                            ? _formatDate(report.createdAt!)
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
      ),
    );
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
}

class AnalyticsTab extends StatefulWidget {
  const AnalyticsTab({super.key});

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  List<ReportModel> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final reports = await DatabaseHelper.instance.getAllReports();
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, double> get _categoryTotals {
    final Map<String, double> totals = {};
    for (final report in _reports) {
      final category = report.category ?? 'Other';
      final amount = report.amount ?? 0.0;
      totals[category] = (totals[category] ?? 0.0) + amount;
    }
    return totals;
  }

  double get _totalAmount {
    return _reports.fold(0.0, (sum, report) => sum + (report.amount ?? 0.0));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Color(0xFF6B7280),
            ),
            const SizedBox(height: 16),
            Text(
              'No data for analytics',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create some reports to see analytics',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Text(
            'Summary',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Reports',
                  '${_reports.length}',
                  Icons.assessment,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Total Amount',
                  'TSh ${_totalAmount.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Category Breakdown
          Text(
            'Category Breakdown',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          
          const SizedBox(height: 16),
          
          ..._categoryTotals.entries.map((entry) => _buildCategoryCard(
            entry.key,
            entry.value,
            _getCategoryColor(entry.key),
          )),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
              ),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String category, double amount, Color color) {
    final percentage = _totalAmount > 0 ? (amount / _totalAmount) * 100 : 0.0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'TSh ${amount.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
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