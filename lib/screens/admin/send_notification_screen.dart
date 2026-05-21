import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/notification_service.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});
  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _selectedType = 'general';
  bool _isSubmitting = false;
  bool _isSuccess = false;

  final List<Map<String, dynamic>> _types = [
    {'value': 'general', 'label': 'General', 'icon': Icons.notifications_outlined},
    {'value': 'event', 'label': 'Event', 'icon': Icons.event_outlined},
    {'value': 'donation', 'label': 'Donation', 'icon': Icons.favorite_outline},
    {'value': 'live', 'label': 'Live Service', 'icon': Icons.live_tv_outlined},
    {'value': 'bulletin', 'label': 'Bulletin', 'icon': Icons.article_outlined},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await NotificationService.sendNotificationToAll(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        type: _selectedType,
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
          const Text('Send Notification',
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
                  Icon(Icons.info_outline, color: AppTheme.navy, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This notification will be sent to all church members.',
                      style: TextStyle(fontSize: 13, color: AppTheme.navy),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Type selection
            const Text('Notification Type',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                    color: AppTheme.navy)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _types.map((type) {
                final isSelected = _selectedType == type['value'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = type['value']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.navy : AppTheme.navyLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(type['icon'] as IconData, size: 14,
                            color: isSelected ? AppTheme.white : AppTheme.navy),
                        const SizedBox(width: 6),
                        Text(type['label'] as String,
                            style: TextStyle(fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? AppTheme.white : AppTheme.navy)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Title
            const Text('Title',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                    color: AppTheme.navy)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Notification title'),
              validator: (v) => v!.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),

            // Body
            const Text('Message',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                    color: AppTheme.navy)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _bodyController,
              maxLines: 4,
              decoration: const InputDecoration(
                  hintText: 'Write your message here...'),
              validator: (v) => v!.trim().isEmpty ? 'Message is required' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _send,
              child: _isSubmitting
                  ? const SizedBox(height: 22, width: 22,
                      child: CircularProgressIndicator(
                          color: AppTheme.white, strokeWidth: 2.5))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Send to All Members'),
                      ],
                    ),
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
            const Text('Notification Sent!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                    color: AppTheme.navy)),
            const SizedBox(height: 12),
            const Text(
              'Your notification has been sent to all members.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppTheme.textSecondary,
                  height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() {
                _isSuccess = false;
                _titleController.clear();
                _bodyController.clear();
              }),
              child: const Text('Send Another',
                  style: TextStyle(color: AppTheme.navy)),
            ),
          ],
        ),
      ),
    );
  }
}
