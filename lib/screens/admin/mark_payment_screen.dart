import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/payment_service.dart';

class MarkPaymentScreen extends StatefulWidget {
  final String memberId;
  final String memberName;
  const MarkPaymentScreen({
    super.key,
    required this.memberId,
    required this.memberName,
  });
  @override
  State<MarkPaymentScreen> createState() => _MarkPaymentScreenState();
}

class _MarkPaymentScreenState extends State<MarkPaymentScreen> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<String> _selectedMonths = [];
  String _paymentMode = 'Cash';
  bool _isSubmitting = false;
  bool _isSuccess = false;
  final List<String> _paymentModes = ['Cash', 'UPI', 'Cheque', 'Bank Transfer'];
  Map<String, bool> _paidStatus = {};
  final List<String> _months = PaymentService.getLast12Months();

  @override
  void initState() {
    super.initState();
    _loadPaidStatus();
    final now = DateTime.now();
    final currentMonth = PaymentService.getMonthKey(now.year, now.month);
    if (PaymentService.isPaymentDue(now.year, now.month)) {
      _selectedMonths = [currentMonth];
    }
  }

  void _loadPaidStatus() async {
    final status = <String, bool>{};
    for (final month in _months) {
      final payment = await PaymentService.getPaymentStatus(widget.memberId, month);
      status[month] = payment?['isPaid'] == true;
    }
    if (mounted) setState(() => _paidStatus = status);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMonths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one month'),
            backgroundColor: AppTheme.error),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await PaymentService.markPayment(
        memberId: widget.memberId,
        memberName: widget.memberName,
        months: _selectedMonths,
        totalAmount: double.parse(_amountController.text.trim()),
        markedBy: 'Admin',
        paymentMode: _paymentMode,
      );
      if (mounted) setState(() { _isSubmitting = false; _isSuccess = true; });
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _isSuccess ? _buildSuccess() : _buildForm()),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppTheme.white, size: 20),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mark Payment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                        color: AppTheme.white)),
                Text(widget.memberName,
                    style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.navyLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.badge_outlined, color: AppTheme.navy, size: 20),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.memberName,
                          style: const TextStyle(fontSize: 15,
                              fontWeight: FontWeight.w700, color: AppTheme.navy)),
                      Text(widget.memberId,
                          style: const TextStyle(fontSize: 12,
                              color: AppTheme.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Select Month(s)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                    color: AppTheme.navy)),
            const SizedBox(height: 4),
            const Text('Select all months this payment covers',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: _months.map((month) {
                  final isPaid = _paidStatus[month] ?? false;
                  final isSelected = _selectedMonths.contains(month);
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: isPaid ? null : (val) {
                      setState(() {
                        if (val == true) {
                          _selectedMonths.add(month);
                        } else {
                          _selectedMonths.remove(month);
                        }
                      });
                    },
                    title: Text(PaymentService.getMonthName(month),
                        style: TextStyle(fontSize: 14,
                            color: isPaid
                                ? AppTheme.textSecondary
                                : AppTheme.textPrimary)),
                    subtitle: isPaid
                        ? const Text('Already paid',
                            style: TextStyle(fontSize: 11,
                                color: AppTheme.success))
                        : null,
                    secondary: isPaid
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppTheme.success, size: 20)
                        : null,
                    activeColor: AppTheme.navy,
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Total Amount (₹)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                    color: AppTheme.navy)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                  color: AppTheme.navy),
              decoration: const InputDecoration(
                hintText: '0',
                prefixText: '₹ ',
                prefixStyle: TextStyle(fontSize: 22,
                    fontWeight: FontWeight.w700, color: AppTheme.navy),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Amount is required';
                if (double.tryParse(v) == null || double.parse(v) <= 0) {
                  return 'Enter valid amount';
                }
                return null;
              },
            ),
            if (_selectedMonths.length > 1) ...[
              const SizedBox(height: 6),
              Text(
                'Amount will be split equally across ${_selectedMonths.length} months',
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
            const SizedBox(height: 16),
            const Text('Payment Mode',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                    color: AppTheme.navy)),
            const SizedBox(height: 10),
            Row(
              children: _paymentModes.map((mode) {
                final isSelected = _paymentMode == mode;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _paymentMode = mode),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.navy : AppTheme.navyLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(mode, textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? AppTheme.white : AppTheme.navy)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(height: 22, width: 22,
                      child: CircularProgressIndicator(
                          color: AppTheme.white, strokeWidth: 2.5))
                  : const Text('Mark as Paid'),
            ),
          ],
        ),
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
              decoration: const BoxDecoration(
                  color: AppTheme.successLight, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, size: 48, color: AppTheme.success),
            ),
            const SizedBox(height: 24),
            const Text('Payment Recorded!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                    color: AppTheme.navy)),
            const SizedBox(height: 12),
            Text(
              '${_selectedMonths.length} month(s) marked as paid for ${widget.memberName}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15,
                  color: AppTheme.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Members'),
            ),
          ],
        ),
      ),
    );
  }
}
