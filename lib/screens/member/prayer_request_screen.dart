import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

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

  final List<String> _categories = [
    'Health & Healing',
    'Family & Relationships',
    'Financial',
    'Spiritual Growth',
    'Work & Career',
    'Grief & Loss',
    'Other',
  ];

  @override
  void dispose() {
    _requestController.dispose();
    super.dispose();
  }

  void _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _isSubmitted = true;
      });
    }
  }

  void _resetForm() {
    setState(() {
      _isSubmitted = false;
      _requestController.clear();
      _selectedCategory = 'Health & Healing';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isSubmitted ? _buildSuccessState() : _buildForm(),
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
        bottom: 16,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppTheme.white,
              size: 20,
            ),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),
          const Text(
            'Prayer Request',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.white,
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
          children: [
            // Info card
            Container(
              decoration: BoxDecoration(
                color: AppTheme.navyLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              padding: const EdgeInsets.all(16),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline_rounded,
                      color: AppTheme.navy, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your request is confidential',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.navy,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Only our pastoral team can see your prayer request. It will never be shared publicly.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Form card
            Container(
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name (read only)
                  const Text(
                    'Your Name',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.navy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.person_outline_rounded,
                            size: 18, color: AppTheme.textSecondary),
                        SizedBox(width: 10),
                        Text(
                          'John Samuel',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category
                  const Text(
                    'Prayer Category',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.navy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = category),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.navy
                                : AppTheme.navyLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.navy
                                  : AppTheme.border,
                            ),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? AppTheme.white
                                  : AppTheme.navy,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Prayer request text
                  const Text(
                    'Your Prayer Request',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.navy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _requestController,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText:
                          'Share your prayer request here. Our pastoral team will pray for you...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                      alignLabelWithHint: true,
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your prayer request';
                      }
                      if (value.trim().length < 10) {
                        return 'Please provide more details';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Submit button
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRequest,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: AppTheme.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('Submit Prayer Request'),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppTheme.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                size: 44,
                color: AppTheme.success,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Prayer Request Submitted',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.navy,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Our pastoral team has received your prayer request. You are in our prayers.',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
                height: 1.65,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.navyLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '"Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God."',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.navy,
                  height: 1.65,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Philippians 4:6',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.gold,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _resetForm,
              child: const Text('Submit Another Request'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Back to Dashboard',
                style: TextStyle(
                  color: AppTheme.navy,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}