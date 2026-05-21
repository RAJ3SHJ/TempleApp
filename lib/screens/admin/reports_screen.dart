import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../theme/app_theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _isExporting = false;

  // Data
  List<Map<String, dynamic>> _donations = [];
  Map<String, double> _categoryTotals = {};
  Map<String, double> _monthlyTotals = {};
  List<Map<String, dynamic>> _topMembers = [];
  double _grandTotal = 0;
  int _totalMembers = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load all donations
      final donationsSnap = await FirebaseFirestore.instance
          .collection('donations')
          .orderBy('date', descending: true)
          .get();

      final donations = donationsSnap.docs.map((d) => d.data()).toList();

      // Calculate totals
      final categoryTotals = <String, double>{};
      final monthlyTotals = <String, double>{};
      final memberTotals = <String, Map<String, dynamic>>{};
      double grandTotal = 0;

      for (final d in donations) {
        final amount = (d['amount'] as num? ?? 0).toDouble();
        final category = d['category'] as String? ?? 'Other';
        final memberId = d['memberId'] as String? ?? '';
        final memberName = d['memberName'] as String? ?? '';
        final date = (d['date'] as dynamic)?.toDate() as DateTime?;

        grandTotal += amount;
        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;

        if (date != null) {
          final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
          monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + amount;
        }

        if (memberId.isNotEmpty) {
          if (!memberTotals.containsKey(memberId)) {
            memberTotals[memberId] = {
              'name': memberName,
              'id': memberId,
              'amount': 0.0,
              'count': 0,
            };
          }
          memberTotals[memberId]!['amount'] =
              (memberTotals[memberId]!['amount'] as double) + amount;
          memberTotals[memberId]!['count'] =
              (memberTotals[memberId]!['count'] as int) + 1;
        }
      }

      // Sort top members
      final topMembers = memberTotals.values.toList()
        ..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

      // Get member count
      final membersSnap = await FirebaseFirestore.instance
          .collection('members').count().get();

      if (mounted) {
        setState(() {
          _donations = donations;
          _categoryTotals = categoryTotals;
          _monthlyTotals = Map.fromEntries(
            monthlyTotals.entries.toList()
              ..sort((a, b) => a.key.compareTo(b.key))
              ..take(6),
          );
          _topMembers = topMembers.take(5).toList();
          _grandTotal = grandTotal;
          _totalMembers = membersSnap.count ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }

  String _getMonthName(String key) {
    final parts = key.split('-');
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[int.parse(parts[1]) - 1]} ${parts[0]}';
  }

  Future<void> _exportPDF() async {
    setState(() => _isExporting = true);
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text('Grace Bible Church — Donation Report',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),

            // Summary
            pw.Text('Summary', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['Metric', 'Value'],
              data: [
                ['Total Members', '$_totalMembers'],
                ['Total Donations', _formatAmount(_grandTotal)],
                ['Total Transactions', '${_donations.length}'],
              ],
            ),
            pw.SizedBox(height: 20),

            // Category breakdown
            pw.Text('Category Breakdown',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['Category', 'Amount'],
              data: _categoryTotals.entries
                  .map((e) => [e.key, _formatAmount(e.value)])
                  .toList(),
            ),
            pw.SizedBox(height: 20),

            // Top members
            pw.Text('Top Contributors',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['Member', 'ID', 'Total', 'Transactions'],
              data: _topMembers.map((m) => [
                m['name'], m['id'],
                _formatAmount(m['amount'] as double),
                '${m['count']}',
              ]).toList(),
            ),
            pw.SizedBox(height: 20),

            // Recent donations
            pw.Text('Recent Donations',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['Member', 'Category', 'Amount', 'Mode'],
              data: _donations.take(20).map((d) => [
                d['memberName'] ?? '',
                d['category'] ?? '',
                _formatAmount((d['amount'] as num? ?? 0).toDouble()),
                d['mode'] ?? '',
              ]).toList(),
            ),
          ],
        ),
      );

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/GBC_Report_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Grace Bible Church - Donation Report',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'),
              backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(context),
          _buildTabBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.navy))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSummaryTab(),
                      _buildCategoryTab(),
                      _buildMembersTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppTheme.navy,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 8, left: 16, right: 16,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppTheme.white, size: 20),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Reports & Export',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                    color: AppTheme.white)),
          ),
          // Export PDF button
          ElevatedButton.icon(
            onPressed: _isExporting ? null : _exportPDF,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.navy,
              minimumSize: const Size(100, 36),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            icon: _isExporting
                ? const SizedBox(height: 14, width: 14,
                    child: CircularProgressIndicator(strokeWidth: 2,
                        color: AppTheme.navy))
                : const Icon(Icons.picture_as_pdf_outlined, size: 16),
            label: Text(_isExporting ? 'Exporting...' : 'Export PDF',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
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
          Tab(text: 'Summary'),
          Tab(text: 'By Category'),
          Tab(text: 'Top Members'),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // Stats cards
          Row(
            children: [
              Expanded(child: _statCard('Total Collected',
                  _formatAmount(_grandTotal), Icons.account_balance_wallet_outlined)),
              const SizedBox(width: 10),
              Expanded(child: _statCard('Total Members',
                  '$_totalMembers', Icons.people_outline)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _statCard('Transactions',
                  '${_donations.length}', Icons.receipt_long_outlined)),
              const SizedBox(width: 10),
              Expanded(child: _statCard('Categories',
                  '${_categoryTotals.length}', Icons.category_outlined)),
            ],
          ),
          const SizedBox(height: 20),

          // Monthly trend
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('MONTHLY TREND',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary, letterSpacing: 0.8)),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            padding: const EdgeInsets.all(16),
            child: _monthlyTotals.isEmpty
                ? const Center(child: Text('No data yet',
                    style: TextStyle(color: AppTheme.textSecondary)))
                : Column(
                    children: _monthlyTotals.entries.map((entry) {
                      final maxAmount = _monthlyTotals.values
                          .reduce((a, b) => a > b ? a : b);
                      final ratio = maxAmount > 0 ? entry.value / maxAmount : 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: Text(_getMonthName(entry.key),
                                  style: const TextStyle(fontSize: 12,
                                      color: AppTheme.textSecondary)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: ratio.toDouble(),
                                  minHeight: 8,
                                  backgroundColor: AppTheme.navyLight,
                                  valueColor: const AlwaysStoppedAnimation(AppTheme.navy),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 70,
                              child: Text(_formatAmount(entry.value),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.navy)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.navy, size: 22),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                  color: AppTheme.navy)),
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildCategoryTab() {
    if (_categoryTotals.isEmpty) {
      return const Center(child: Text('No donation data yet',
          style: TextStyle(color: AppTheme.textSecondary)));
    }

    final total = _categoryTotals.values.fold(0.0, (a, b) => a + b);
    final colors = [AppTheme.navy, AppTheme.navyMid, AppTheme.gold,
        const Color(0xFF7C3AED), AppTheme.success, AppTheme.error];

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: _categoryTotals.entries.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final cat = entry.value;
              final percentage = total > 0 ? (cat.value / total * 100) : 0;
              final color = colors[index % colors.length];
              final isLast = index == _categoryTotals.length - 1;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12, height: 12,
                              decoration: BoxDecoration(
                                  color: color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(cat.key,
                                  style: const TextStyle(fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.textPrimary)),
                            ),
                            Text('${percentage.toStringAsFixed(1)}%',
                                style: const TextStyle(fontSize: 13,
                                    color: AppTheme.textSecondary)),
                            const SizedBox(width: 12),
                            Text(_formatAmount(cat.value),
                                style: const TextStyle(fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.navy)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: total > 0 ? cat.value / total : 0,
                            minHeight: 6,
                            backgroundColor: AppTheme.navyLight,
                            valueColor: AlwaysStoppedAnimation(color),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    const Divider(height: 1, indent: 14, endIndent: 14,
                        color: AppTheme.border),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMembersTab() {
    if (_topMembers.isEmpty) {
      return const Center(child: Text('No donation data yet',
          style: TextStyle(color: AppTheme.textSecondary)));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: _topMembers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final member = _topMembers[index];
        final name = member['name'] as String;
        final initials = name.split(' ')
            .map((e) => e.isNotEmpty ? e[0] : '')
            .take(2)
            .join()
            .toUpperCase();

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              // Rank
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: index == 0 ? AppTheme.gold :
                      index == 1 ? AppTheme.border : AppTheme.navyLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('${index + 1}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                          color: index == 0 ? Colors.white : AppTheme.navy)),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.navyLight,
                child: Text(initials,
                    style: const TextStyle(fontSize: 12,
                        fontWeight: FontWeight.w700, color: AppTheme.navy)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary)),
                    Text('${member['id']} · ${member['count']} transactions',
                        style: const TextStyle(fontSize: 12,
                            color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Text(_formatAmount(member['amount'] as double),
                  style: const TextStyle(fontSize: 15,
                      fontWeight: FontWeight.w700, color: AppTheme.navy)),
            ],
          ),
        );
      },
    );
  }
}
