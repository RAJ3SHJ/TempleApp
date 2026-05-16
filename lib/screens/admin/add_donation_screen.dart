import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

class AddDonationScreen extends StatefulWidget {
  const AddDonationScreen({super.key});

  @override
  State<AddDonationScreen> createState() => _AddDonationScreenState();
}

class _AddDonationScreenState extends State<AddDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _memberSearchController = TextEditingController();
  final _amountController = TextEditingController();
  final _receiptController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'Tithe';
  String _selectedPaymentMode = 'Cash';
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  bool _memberFound = false;
  String _foundMemberName = '';

  final List<String> _categories = [
    'Tithe', 'Offering', 'Building Fund', 'Special Fund', 'Charity', 'Missions'
  ];

  final List<String> _paymentModes = ['Cash', 'UPI', 'Cheque', 'Bank Transfer'];

  final Map<String, String> _memberDatabase = {
    'GBC-00123': 'John Samuel',
    'GBC-00124': 'Priya Mathew',
    'GBC-00125': 'Thomas Jacob',
    'GBC-00126': 'Anu Kurian',
    'GBC-00127': 'Suresh Philip',
    'GBC-00128': 'Meena Thomas',
  };

  @override
  void dispose() {
    _memberSearchController.dispose();
    _amountController.dispose();
    _receiptController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _searchMember(String query) {
    final found = _memberDatabase[query.toUpperCase()];
    setState(() {
      _memberFound = found != null;
      _foundMemberName = found ?? '';
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_memberFound) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please search and select a valid member first.')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() { _isSubmitting = false; _isSubmitted = true; });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.navy),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String get _formattedDate {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${_selectedDate.day} ${months[_selectedDate.month - 1]} ${_selectedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _isSubmitted ? _buildSuccess() : _buildForm()),
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
          const Text('Add Donation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.white)),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Member Search
            _buildSectionCard(
              title: 'Member',
              icon: Icons.person_outline_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Search by Member ID',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.navy)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _memberSearchController,
                          textCapitalization: TextCapitalization.characters,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 2),
                          decoration: const InputDecoration(
                            hintText: 'GBC-00123',
                            prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.navy, size: 20),
                          ),
                          onChanged: _searchMember,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.navy,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () => _searchMember(_memberSearchController.text),
                          icon: const Icon(Icons.search_rounded, color: AppTheme.white),
                        ),
                      ),
                    ],
                  ),
                  if (_memberFound) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.successLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, color: AppTheme.success, size: 18),
                          const SizedBox(width: 8),
                          Text(_foundMemberName,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.success)),
                          const SizedBox(width: 6),
                          Text('(${_memberSearchController.text.toUpperCase()})',
                              style: const TextStyle(fontSize: 12, color: AppTheme.success)),
                        ],
                      ),
                    ),
                  ] else if (_memberSearchController.text.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.errorLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 18),
                          SizedBox(width: 8),
                          Text('Member not found', style: TextStyle(fontSize: 14, color: AppTheme.error)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Amount
            _buildSectionCard(
              title: 'Amount',
              icon: Icons.account_balance_wallet_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Amount (₹)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.navy)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppTheme.navy),
                    decoration: const InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppTheme.border),
                      prefixText: '₹ ',
                      prefixStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.navy),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Amount is required';
                      if (int.tryParse(v) == null || int.parse(v) <= 0) return 'Enter a valid amount';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Category
            _buildSectionCard(
              title: 'Category',
              icon: Icons.tag_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Donation Category',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.navy)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = category),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.navy : AppTheme.navyLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(category,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                                  color: isSelected ? AppTheme.white : AppTheme.navy)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Payment Details
            _buildSectionCard(
              title: 'Payment Details',
              icon: Icons.payment_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment Mode
                  const Text('Payment Mode',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.navy)),
                  const SizedBox(height: 10),
                  Row(
                    children: _paymentModes.map((mode) {
                      final isSelected = _selectedPaymentMode == mode;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedPaymentMode = mode),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.navy : AppTheme.navyLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(mode, textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                                    color: isSelected ? AppTheme.white : AppTheme.navy)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Date
                  const Text('Date of Payment',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.navy)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: AppTheme.navy, size: 18),
                          const SizedBox(width: 10),
                          Text(_formattedDate,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                          const Spacer(),
                          const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Receipt Number
                  const Text('Receipt Number',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.navy)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _receiptController,
                    decoration: const InputDecoration(
                      hintText: 'RC-0000',
                      prefixIcon: Icon(Icons.receipt_outlined, color: AppTheme.navy, size: 20),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Receipt number is required' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Notes
            _buildSectionCard(
              title: 'Notes (Optional)',
              icon: Icons.notes_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Additional Notes',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.navy)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Any additional notes about this donation...',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(height: 22, width: 22,
                      child: CircularProgressIndicator(color: AppTheme.white, strokeWidth: 2.5))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Save Donation'),
                      ],
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.navy),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.navy)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.border),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90, height: 90,
              decoration: const BoxDecoration(color: AppTheme.successLight, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, size: 48, color: AppTheme.success),
            ),
            const SizedBox(height: 24),
            const Text('Donation Saved!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.navy)),
            const SizedBox(height: 12),
            Text('₹${_amountController.text} ${_selectedCategory} recorded for $_foundMemberName.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary, height: 1.5)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.navyLight, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _summaryRow('Member', _foundMemberName),
                  _summaryRow('Amount', '₹${_amountController.text}'),
                  _summaryRow('Category', _selectedCategory),
                  _summaryRow('Payment Mode', _selectedPaymentMode),
                  _summaryRow('Date', _formattedDate),
                  _summaryRow('Receipt', _receiptController.text),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Dashboard'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() {
                _isSubmitted = false;
                _amountController.clear();
                _receiptController.clear();
                _notesController.clear();
                _memberSearchController.clear();
                _memberFound = false;
                _foundMemberName = '';
              }),
              child: const Text('Add Another Donation',
                  style: TextStyle(color: AppTheme.navy, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.navy)),
        ],
      ),
    );
  }
}