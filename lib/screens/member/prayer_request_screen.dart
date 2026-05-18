import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';

class PrayerRequestScreen extends StatefulWidget {
  const PrayerRequestScreen({super.key});
  @override
  State<PrayerRequestScreen> createState() => _PrayerRequestScreenState();
}

class _PrayerRequestScreenState extends State<PrayerRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _requestController = TextEditingController();
  String _selectedCategory = 'Health & Healing';
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  bool _isAnonymous = false;
  String _memberName = '';
  String _memberId = '';

  final List<String> _categories = [
    'Health & Healing', 'Family & Relationships', 'Financial',
    'Spiritual Growth', 'Work & Career', 'Grief & Loss', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadMemberData();
  }

  void _loadMemberData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('members').doc(user.uid).get();
      if (mounted && doc.exists) {
        setState(() {
          _memberName = doc.data()?['name'] ?? '';
          _memberId = doc.data()?['memberId'] ?? '';
        });
      }
    }
  }

  @override
  void dispose() {
    _requestController.dispose();
    super.dispose();
  }

  void _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await FirebaseService.addPrayerRequest(
        memberId: _memberId,
        memberName: _memberName,
        request: '${_selectedCategory}: ${_requestController.text.trim()}',
        isAnonymous: _isAnonymous,
      );
      if (mounted) setState(() { _isSubmitting = false; _isSubmitted = true; });
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'),
              backgroundColor: AppTheme.error),
        );
      }
    }
  }

  void _resetForm() {
    setState(() {
      _isSubmitted = false;
      _requestController.clear();
      _selectedCategory = 'Health & Healing';
      _isAnonymous = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _isSubmitted ? _buildSuccess() : _buildForm()),
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
          const Text('Prayer Request',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                  color: AppTheme.white)),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.navyLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.favorite_outline, color: AppTheme.navy, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Share your prayer needs with our pastoral team. All requests are kept confidential.',
                      style: TextStyle(fontSize: 13, color: AppTheme.navy, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Category
            const Text('Category',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                    color: AppTheme.navy)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.navy : AppTheme.navyLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(cat,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                            color: isSelected ? AppTheme.white : AppTheme.navy)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Request text
            const Text('Your Prayer Request',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                    color: AppTheme.navy)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _requestController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Share what you would like us to pray for...',
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Please enter your prayer request' : null,
            ),
            const SizedBox(height: 16),

            // Anonymous option
            Container(
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: SwitchListTile(
                value: _isAnonymous,
                onChanged: (val) => setState(() => _isAnonymous = val),
                title: const Text('Submit Anonymously',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary)),
                subtitle: const Text('Your name will not be shown',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                activeColor: AppTheme.navy,
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitRequest,
              child: _isSubmitting
                  ? const SizedBox(height: 22, width: 22,
                      child: CircularProgressIndicator(
                          color: AppTheme.white, strokeWidth: 2.5))
                  : const Text('Submit Prayer Request'),
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
              child: const Icon(Icons.favorite, size: 48, color: AppTheme.success),
            ),
            const SizedBox(height: 24),
            const Text('Prayer Request Submitted!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                    color: AppTheme.navy)),
            const SizedBox(height: 12),
            const Text(
              'Our pastoral team will be praying for you. You are not alone.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppTheme.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _resetForm,
              child: const Text('Submit Another Request',
                  style: TextStyle(color: AppTheme.navy)),
            ),
          ],
        ),
      ),
    );
  }
}
