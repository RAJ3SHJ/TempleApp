import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class DonationRecord {
  final String memberName;
  final String memberId;
  final String category;
  final int amount;
  final String date;
  final DateTime dateTime;
  final String paymentMode;
  final String receiptNo;

  DonationRecord({
    required this.memberName,
    required this.memberId,
    required this.category,
    required this.amount,
    required this.date,
    required this.dateTime,
    required this.paymentMode,
    required this.receiptNo,
  });
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedPaymentMode = 'All';
  DateTimeRange? _selectedDateRange;
  bool _hasSearched = false;

  final List<DonationRecord> _allRecords = [
    DonationRecord(memberName: 'John Samuel', memberId: 'GBC-00123', category: 'Tithe',
        amount: 5000, date: '09 May 2026', dateTime: DateTime(2026, 5, 9), paymentMode: 'Cash', receiptNo: 'RC-0091'),
    DonationRecord(memberName: 'Priya Mathew', memberId: 'GBC-00124', category: 'Offering',
        amount: 1200, date: '09 May 2026', dateTime: DateTime(2026, 5, 9), paymentMode: 'UPI', receiptNo: 'RC-0090'),
    DonationRecord(memberName: 'Thomas Jacob', memberId: 'GBC-00125', category: 'Building Fund',
        amount: 10000, date: '08 May 2026', dateTime: DateTime(2026, 5, 8), paymentMode: 'Cheque', receiptNo: 'RC-0089'),
    DonationRecord(memberName: 'John Samuel', memberId: 'GBC-00123', category: 'Offering',
        amount: 1500, date: '02 May 2026', dateTime: DateTime(2026, 5, 2), paymentMode: 'UPI', receiptNo: 'RC-0088'),
    DonationRecord(memberName: 'Anu Kurian', memberId: 'GBC-00126', category: 'Tithe',
        amount: 5000, date: '01 May 2026', dateTime: DateTime(2026, 5, 1), paymentMode: 'Cash', receiptNo: 'RC-0087'),
    DonationRecord(memberName: 'Suresh Philip', memberId: 'GBC-00127', category: 'Special Fund',
        amount: 2500, date: '28 Apr 2026', dateTime: DateTime(2026, 4, 28), paymentMode: 'UPI', receiptNo: 'RC-0086'),
    DonationRecord(memberName: 'Meena Thomas', memberId: 'GBC-00128', category: 'Tithe',
        amount: 5000, date: '20 Apr 2026', dateTime: DateTime(2026, 4, 20), paymentMode: 'Cash', receiptNo: 'RC-0085'),
    DonationRecord(memberName: 'Thomas Jacob', memberId: 'GBC-00125', category: 'Building Fund',
        amount: 10000, date: '15 Apr 2026', dateTime: DateTime(2026, 4, 15), paymentMode: 'Cheque', receiptNo: 'RC-0084'),
    DonationRecord(memberName: 'Priya Mathew', memberId: 'GBC-00124', category: 'Tithe',
        amount: 5000, date: '01 Apr 2026', dateTime: DateTime(2026, 4, 1), paymentMode: 'Cash', receiptNo: 'RC-0083'),
    DonationRecord(memberName: 'John Samuel', memberId: 'GBC-00123', category: 'Special Fund',
        amount: 3000, date: '25 Mar 2026', dateTime: DateTime(2026, 3, 25), paymentMode: 'UPI', receiptNo: 'RC-0082'),
  ];

  List<DonationRecord> get _filteredRecords {
    if (!_hasSearched) return [];
    return _allRecords.where((r) {
      final matchesSearch = _searchQuery.isEmpty ||
          r.memberName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.memberId.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || r.category == _selectedCategory;
      final matchesMode = _selectedPaymentMode == 'All' || r.paymentMode == _selectedPaymentMode;
      final matchesDate = _selectedDateRange == null ||
          (r.dateTime.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
           r.dateTime.isBefore(_selectedDateRange!.end.add(const Duration(days: 1))));
      return matchesSearch && matchesCategory && matchesMode && matchesDate;
    }).toList();
  }

  int get _totalAmount => _filteredRecords.fold(0, (sum, r) => sum + r.amount);

  void _search() => setState(() => _hasSearched = true);

  void _reset() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = 'All';
      _selectedPaymentMode = 'All';
      _selectedDateRange = null;
      _hasSearched = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _buildSearchCard(),
                  const SizedBox(height: 12),
                  _buildFilterCard(),
                  const SizedBox(height: 12),
                  _buildActionButtons(),
                  const SizedBox(height: 16),
                  if (_hasSearched) ...[
                    _buildResultsHeader(),
                    const SizedBox(height: 10),
                    _buildResults(),
                  ],
                ],
              ),
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
          const Text('Search & Filter',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.white)),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
      decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.search_rounded, size: 18, color: AppTheme.navy),
            SizedBox(width: 8),
            Text('Search Member', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.navy)),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.border),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search by name or Member ID...',
              prefixIcon: const Icon(Icons.person_search_outlined, color: AppTheme.navy, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: AppTheme.textSecondary),
                      onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); },
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    final categories = ['All', 'Tithe', 'Offering', 'Building Fund', 'Special Fund', 'Charity'];
    final paymentModes = ['All', 'Cash', 'UPI', 'Cheque', 'Bank Transfer'];

    return Container(
      decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.filter_list_rounded, size: 18, color: AppTheme.navy),
            SizedBox(width: 8),
            Text('Filters', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.navy)),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.border),
          const SizedBox(height: 14),
          const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.navy)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: categories.map((cat) {
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
          const SizedBox(height: 16),
          const Text('Payment Mode', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.navy)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: paymentModes.map((mode) {
              final isSelected = _selectedPaymentMode == mode;
              return GestureDetector(
                onTap: () => setState(() => _selectedPaymentMode = mode),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.navy : AppTheme.navyLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(mode, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                      color: isSelected ? AppTheme.white : AppTheme.navy)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('Date Range', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.navy)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2019),
                lastDate: DateTime.now(),
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
                color: _selectedDateRange != null ? AppTheme.navyLight : AppTheme.white,
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
                        : 'Select date range',
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
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Reset'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.navy,
              side: const BorderSide(color: AppTheme.navy),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _search,
            icon: const Icon(Icons.search_rounded, size: 18),
            label: const Text('Search Records'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsHeader() {
    return Row(
      children: [
        Text('${_filteredRecords.length} RESULTS FOUND',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary, letterSpacing: 0.8)),
        const Spacer(),
        if (_filteredRecords.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppTheme.navyLight, borderRadius: BorderRadius.circular(20)),
            child: Text('Total: ₹$_totalAmount',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.navy)),
          ),
      ],
    );
  }

  Widget _buildResults() {
    if (_filteredRecords.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.search_off_rounded, size: 48, color: AppTheme.textSecondary.withOpacity(0.4)),
              const SizedBox(height: 12),
              const Text('No records found', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
              const SizedBox(height: 4),
              const Text('Try adjusting your search or filters', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
      child: Column(
        children: _filteredRecords.asMap().entries.map((entry) {
          final isLast = entry.key == _filteredRecords.length - 1;
          final record = entry.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.navyLight,
                      child: Text(record.memberName.split(' ').map((e) => e[0]).take(2).join(),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.navy)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(record.memberName,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                          Text('${record.memberId} · ${record.category} · ${record.date}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                          Text('${record.paymentMode} · ${record.receiptNo}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                    Text('₹${record.amount}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.navy)),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1, indent: 14, endIndent: 14, color: AppTheme.border),
            ],
          );
        }).toList(),
      ),
    );
  }
}