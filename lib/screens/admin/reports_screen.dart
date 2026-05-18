import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';
  DateTimeRange? _selectedDateRange;
  bool _isExporting = false;
  String _exportingFormat = '';

  final List<String> _categories = ['All', 'Tithe', 'Offering', 'Building Fund', 'Special Fund'];

  final List<Map<String, dynamic>> _monthlyData = [
    {'month': 'Jan', 'amount': 180000},
    {'month': 'Feb', 'amount': 220000},
    {'month': 'Mar', 'amount': 195000},
    {'month': 'Apr', 'amount': 310000},
    {'month': 'May', 'amount': 342000},
  ];

  final List<Map<String, dynamic>> _categoryData = [
    {'name': 'Tithe', 'amount': 620000, 'percentage': 50, 'color': AppTheme.navy},
    {'name': 'Offering', 'amount': 280000, 'percentage': 22, 'color': AppTheme.navyMid},
    {'name': 'Building Fund', 'amount': 240000, 'percentage': 19, 'color': AppTheme.gold},
    {'name': 'Special Fund', 'amount': 100000, 'percentage': 8, 'color': Color(0xFF7C3AED)},
    {'name': 'Charity', 'amount': 10000, 'percentage': 1, 'color': AppTheme.success},
  ];

  final List<Map<String, dynamic>> _topMembers = [
    {'name': 'Thomas Jacob', 'id': 'GBC-00125', 'amount': 120000, 'donations': 12},
    {'name': 'Sarah Mathew', 'id': 'GBC-00128', 'amount': 95000, 'donations': 9},
    {'name': 'John Samuel', 'id': 'GBC-00123', 'amount': 85000, 'donations': 8},
    {'name': 'Suresh Philip', 'id': 'GBC-00127', 'amount': 72000, 'donations': 7},
    {'name': 'Priya Mathew', 'id': 'GBC-00124', 'amount': 65000, 'donations': 6},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _export(String format) async {
    setState(() { _isExporting = true; _exportingFormat = format; });
    await Future.delayed(const Duration(seconds: 2));
    setState(() { _isExporting = false; _exportingFormat = ''; });
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(children: [
            const Icon(Icons.check_circle_outline_rounded, color: AppTheme.success, size: 24),
            const SizedBox(width: 8),
            Text('$format Export Ready',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.navy)),
          ]),
          content: Text(
            'Your $format report has been prepared. In the live app with Firebase, this will download as a $format file to your device.',
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
          ),
          actions: [
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  String _formatAmount(int amount) {
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(0)}K';
    return '₹$amount';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildCategoryTab(),
                _buildExportTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppTheme.navy,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 16, left: 16, right: 16,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.white, size: 20),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),
          const Text('Reports & Export',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.white)),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.navy,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.white,
        indicatorWeight: 3,
        labelColor: AppTheme.white,
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'By Category'),
          Tab(text: 'Export'),
        ],
      ),
    );
  }

  // ── OVERVIEW TAB ──
  Widget _buildOverviewTab() {
    final totalYear = _monthlyData.fold(0, (sum, m) => sum + (m['amount'] as int));
    final maxAmount = _monthlyData.map((m) => m['amount'] as int).reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _summaryCard('Total This Year', '₹12.4L', Icons.calendar_today_outlined, AppTheme.navy)),
              const SizedBox(width: 10),
              Expanded(child: _summaryCard('Total Members', '2,847', Icons.people_outline, AppTheme.navyMid)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _summaryCard('This Month', '₹3.4L', Icons.trending_up_outlined, AppTheme.success)),
              const SizedBox(width: 10),
              Expanded(child: _summaryCard('All Time', '₹48.2L', Icons.account_balance_outlined, AppTheme.gold)),
            ],
          ),
          const SizedBox(height: 16),

          _sectionLabel('Monthly Collections — 2026'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  height: 160,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _monthlyData.map((data) {
                      final amount = data['amount'] as int;
                      final barHeight = (amount / maxAmount) * 130;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(_formatAmount(amount),
                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.navy)),
                              const SizedBox(height: 4),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 600),
                                height: barHeight,
                                decoration: BoxDecoration(color: AppTheme.navy, borderRadius: BorderRadius.circular(6)),
                              ),
                              const SizedBox(height: 6),
                              Text(data['month'] as String,
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Total: ${_formatAmount(totalYear)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.navy)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _sectionLabel('Top Contributors'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
            child: Column(
              children: _topMembers.asMap().entries.map((entry) {
                final isLast = entry.key == _topMembers.length - 1;
                final member = entry.value;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 32, height: 32,
                            decoration: const BoxDecoration(color: AppTheme.navy, shape: BoxShape.circle),
                            child: Center(child: Text('${entry.key + 1}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.white))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(member['name'] as String,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                              Text('${member['id']} · ${member['donations']} donations',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                            ]),
                          ),
                          Text(_formatAmount(member['amount'] as int),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.navy)),
                        ],
                      ),
                    ),
                    if (!isLast) const Divider(height: 1, indent: 14, endIndent: 14, color: AppTheme.border),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── CATEGORY TAB ──
  Widget _buildCategoryTab() {
    final total = _categoryData.fold(0, (sum, c) => sum + (c['amount'] as int));
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Collection by Category — 2026'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppTheme.navyLight, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Collections', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.navy)),
                      Text(_formatAmount(total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.navy)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ..._categoryData.map((cat) {
                  final percentage = cat['percentage'] as int;
                  final color = cat['color'] as Color;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              Text(cat['name'] as String,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                            ]),
                            Row(children: [
                              Text(_formatAmount(cat['amount'] as int),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.navy)),
                              const SizedBox(width: 8),
                              Text('$percentage%', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                            ]),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: AppTheme.border,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── EXPORT TAB ──
  Widget _buildExportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Export Donation Records'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Range
                const Text('Date Range', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.navy)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2019), lastDate: DateTime.now(),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppTheme.navy)),
                        child: child!,
                      ),
                    );
                    if (picked != null) setState(() => _selectedDateRange = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedDateRange != null ? AppTheme.navyLight : AppTheme.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _selectedDateRange != null ? AppTheme.navy : AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.date_range_outlined,
                            color: _selectedDateRange != null ? AppTheme.navy : AppTheme.textSecondary, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          _selectedDateRange != null
                              ? '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.year} — ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}'
                              : 'Select date range (optional)',
                          style: TextStyle(fontSize: 14,
                              color: _selectedDateRange != null ? AppTheme.navy : AppTheme.textSecondary),
                        ),
                        const Spacer(),
                        if (_selectedDateRange != null)
                          GestureDetector(
                            onTap: () => setState(() => _selectedDateRange = null),
                            child: const Icon(Icons.close_rounded, size: 16, color: AppTheme.navy),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category
                const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.navy)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.navy : AppTheme.navyLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(cat, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                            color: isSelected ? AppTheme.white : AppTheme.navy)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Export Format
                const Text('Export Format', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.navy)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Excel
                    Expanded(
                      child: GestureDetector(
                        onTap: _isExporting ? null : () => _export('Excel (.xlsx)'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _exportingFormat == 'Excel (.xlsx)' ? AppTheme.success.withOpacity(0.2) : AppTheme.successLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.success.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              _exportingFormat == 'Excel (.xlsx)'
                                  ? const SizedBox(height: 28, width: 28, child: CircularProgressIndicator(color: AppTheme.success, strokeWidth: 2.5))
                                  : const Icon(Icons.table_chart_outlined, color: AppTheme.success, size: 28),
                              const SizedBox(height: 6),
                              const Text('Excel (.xlsx)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.success)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // CSV
                    Expanded(
                      child: GestureDetector(
                        onTap: _isExporting ? null : () => _export('CSV (.csv)'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _exportingFormat == 'CSV (.csv)' ? AppTheme.navy.withOpacity(0.2) : AppTheme.navyLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.navy.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              _exportingFormat == 'CSV (.csv)'
                                  ? const SizedBox(height: 28, width: 28, child: CircularProgressIndicator(color: AppTheme.navy, strokeWidth: 2.5))
                                  : const Icon(Icons.description_outlined, color: AppTheme.navy, size: 28),
                              const SizedBox(height: 6),
                              const Text('CSV (.csv)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.navy)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // PDF
                    Expanded(
                      child: GestureDetector(
                        onTap: _isExporting ? null : () => _export('PDF (.pdf)'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _exportingFormat == 'PDF (.pdf)' ? AppTheme.error.withOpacity(0.2) : AppTheme.errorLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              _exportingFormat == 'PDF (.pdf)'
                                  ? const SizedBox(height: 28, width: 28, child: CircularProgressIndicator(color: AppTheme.error, strokeWidth: 2.5))
                                  : const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.error, size: 28),
                              const SizedBox(height: 6),
                              const Text('PDF (.pdf)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.error)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: AppTheme.border),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.textSecondary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Export will include all donation records matching the selected filters. Firebase integration required for actual file download.',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ]),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(label.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary, letterSpacing: 0.8));
  }
}