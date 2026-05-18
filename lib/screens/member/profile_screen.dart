import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String memberId;
  const ProfileScreen({super.key, required this.memberId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _memberData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMemberData();
  }

  void _loadMemberData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('members')
            .doc(user.uid)
            .get();
        if (mounted && doc.exists) {
          setState(() {
            _memberData = doc.data();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getInitials(String name) {
    return name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator(color: AppTheme.navy)),
      );
    }

    final name = _memberData?['name'] ?? 'Member';
    final phone = _memberData?['phone'] ?? '-';
    final email = _memberData?['email'] ?? '-';
    final address = _memberData?['address'] ?? '-';
    final sector = _memberData?['sector'] ?? '';
    final memberId = _memberData?['memberId'] ?? widget.memberId;
    final createdAt = _memberData?['createdAt'] as dynamic;
    String joinedDate = '-';
    if (createdAt != null) {
      final dt = (createdAt).toDate() as DateTime;
      joinedDate = '${_monthName(dt.month)} ${dt.year}';
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(context, name, memberId),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _buildInfoCard(phone, email, joinedDate, address, sector),
                  const SizedBox(height: 12),
                  _buildSettingsCard(context),
                  const SizedBox(height: 12),
                  _buildSignOutCard(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Widget _buildHeader(BuildContext context, String name, String memberId) {
    return Container(
      color: AppTheme.navy,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 28, left: 16, right: 16,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.white, size: 20),
                padding: EdgeInsets.zero,
              ),
              const Text('My Profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.white)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: 72, height: 72,
            decoration: const BoxDecoration(color: AppTheme.white, shape: BoxShape.circle),
            child: Center(
              child: Text(_getInitials(name),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppTheme.navy)),
            ),
          ),
          const SizedBox(height: 12),
          Text(name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.white)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('Member ID: $memberId',
                style: const TextStyle(fontSize: 13, color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String phone, String email, String joinedDate, String address, String sector) {
    final details = [
      {'icon': Icons.phone_outlined, 'label': 'Phone', 'value': phone},
      {'icon': Icons.mail_outline_rounded, 'label': 'Email', 'value': email},
      {'icon': Icons.calendar_today_outlined, 'label': 'Member Since', 'value': joinedDate},
      {'icon': Icons.location_on_outlined, 'label': 'Address', 'value': address},
      if (sector.isNotEmpty)
        {'icon': Icons.map_outlined, 'label': 'Sector', 'value': sector},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: details.asMap().entries.map((entry) {
          final index = entry.key;
          final detail = entry.value;
          final isLast = index == details.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                          color: AppTheme.navyLight, borderRadius: BorderRadius.circular(10)),
                      child: Icon(detail['icon'] as IconData, size: 18, color: AppTheme.navy),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(detail['label'] as String,
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        const SizedBox(height: 2),
                        Text(detail['value'] as String,
                            style: const TextStyle(fontSize: 15,
                                fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(height: 1, indent: 16, endIndent: 16, color: AppTheme.border),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          // Change Password
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                        color: AppTheme.navyLight, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.lock_outline_rounded, size: 18, color: AppTheme.navy),
                  ),
                  const SizedBox(width: 12),
                  const Text('Change Password',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary, size: 20),
                ],
              ),
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16, color: AppTheme.border),
          InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                        color: AppTheme.navyLight, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.notifications_outlined, size: 18, color: AppTheme.navy),
                  ),
                  const SizedBox(width: 12),
                  const Text('Notification Settings',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary, size: 20),
                ],
              ),
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16, color: AppTheme.border),
          InkWell(
            onTap: () {},
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                        color: AppTheme.navyLight, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.help_outline_rounded, size: 18, color: AppTheme.navy),
                  ),
                  const SizedBox(width: 12),
                  const Text('Help & Support',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: InkWell(
        onTap: () => _showSignOutDialog(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                    color: AppTheme.errorLight, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.logout_rounded, size: 18, color: AppTheme.error),
              ),
              const SizedBox(width: 12),
              const Text('Sign Out',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.error)),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        content: const Text('Are you sure you want to sign out?',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              minimumSize: const Size(80, 38),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

// ── CHANGE PASSWORD SCREEN ──
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text.trim(),
      );

      // Re-authenticate first
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(_newPasswordController.text.trim());

      if (mounted) setState(() { _isLoading = false; _isSuccess = true; });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.code == 'wrong-password'
            ? 'Current password is incorrect.'
            : 'Failed to change password. Please try again.';
      });
    } catch (e) {
      setState(() { _isLoading = false; _errorMessage = 'Something went wrong.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          Container(
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
                const Text('Change Password',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.white)),
              ],
            ),
          ),
          Expanded(
            child: _isSuccess ? _buildSuccess(context) : _buildForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text('Current Password',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.navy)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _currentPasswordController,
              obscureText: _obscureCurrent,
              decoration: InputDecoration(
                hintText: 'Enter current password',
                prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.navy, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(_obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppTheme.textSecondary, size: 20),
                  onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                ),
              ),
              validator: (v) => v!.isEmpty ? 'Current password is required' : null,
            ),
            const SizedBox(height: 16),
            const Text('New Password',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.navy)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                hintText: 'Minimum 6 characters',
                prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.navy, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(_obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppTheme.textSecondary, size: 20),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'New password is required';
                if (v.length < 6) return 'Minimum 6 characters required';
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('Confirm New Password',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.navy)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                hintText: 'Re-enter new password',
                prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.navy, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppTheme.textSecondary, size: 20),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please confirm your password';
                if (v != _newPasswordController.text) return 'Passwords do not match';
                return null;
              },
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                    color: AppTheme.errorLight, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_errorMessage!,
                        style: const TextStyle(color: AppTheme.error, fontSize: 13))),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _isLoading ? null : _changePassword,
              child: _isLoading
                  ? const SizedBox(height: 22, width: 22,
                      child: CircularProgressIndicator(color: AppTheme.white, strokeWidth: 2.5))
                  : const Text('Update Password'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess(BuildContext context) {
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
            const Text('Password Updated!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.navy)),
            const SizedBox(height: 12),
            const Text('Your password has been changed successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppTheme.textSecondary, height: 1.5)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
