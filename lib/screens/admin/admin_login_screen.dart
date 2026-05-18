import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import 'admin_dashboard_screen.dart';
import 'super_admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final username = _usernameController.text.trim().toLowerCase();
      final password = _passwordController.text.trim();

      // Look up admin by username in Firestore
      final query = await FirebaseFirestore.instance
          .collection('admins')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        setState(() { _isLoading = false; _errorMessage = 'Username not found.'; });
        return;
      }

      final adminDoc = query.docs.first;
      final adminData = adminDoc.data();
      final email = adminData['email'] as String;
      final role = adminData['role'] as String? ?? 'admin';
      final isTempPassword = adminData['isTempPassword'] as bool? ?? false;
      final tempPasswordExpiry = adminData['tempPasswordExpiry'] as Timestamp?;

      // Check if temp password has expired
      if (isTempPassword && tempPasswordExpiry != null) {
        if (DateTime.now().isAfter(tempPasswordExpiry.toDate())) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Your temporary password has expired. Contact Super Admin to reset.';
          });
          return;
        }
      }

      // Sign in with Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      // If temp password → force change password screen
      if (isTempPassword) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeAdminPasswordScreen(
              adminDocId: adminDoc.id,
              adminName: adminData['name'] as String? ?? username,
              email: email,
            ),
          ),
        );
        return;
      }

      // Route based on role
      if (role == 'superadmin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SuperAdminDashboardScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminDashboardScreen(
              adminName: adminData['name'] as String? ?? username,
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.code == 'wrong-password'
            ? 'Incorrect password. Please try again.'
            : 'Login failed. Please try again.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    return Scaffold(
      backgroundColor: AppTheme.navy,
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildMobileHeader(),
        Expanded(
          child: Container(
            color: AppTheme.background,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildForm(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      color: AppTheme.navy,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 32,
        bottom: 28, left: 24, right: 24,
      ),
      child: Column(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_outlined, size: 36, color: AppTheme.white),
          ),
          const SizedBox(height: 16),
          const Text('Admin Portal',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.white)),
          const SizedBox(height: 4),
          const Text('Grace Bible Church',
              style: TextStyle(fontSize: 14, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            color: AppTheme.navy,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.church_rounded, size: 52, color: AppTheme.white),
                  ),
                  const SizedBox(height: 24),
                  const Text('Grace Bible Church',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.white)),
                  const SizedBox(height: 8),
                  const Text('123, Mission Road, Hyderabad – 500001',
                      style: TextStyle(fontSize: 14, color: Colors.white70)),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            color: AppTheme.background,
            child: Center(
              child: Container(
                width: 420,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 8)),
                  ],
                ),
                child: _buildForm(isDesktop: true),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm({bool isDesktop = false}) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop) ...[
            const Icon(Icons.shield_outlined, size: 40, color: AppTheme.navy),
            const SizedBox(height: 16),
          ],
          Text('Admin Sign In',
              style: TextStyle(fontSize: isDesktop ? 28 : 24, fontWeight: FontWeight.w700, color: AppTheme.navy)),
          const SizedBox(height: 6),
          const Text('Authorized personnel only',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
          const SizedBox(height: 32),
          const Text('Username',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.navy)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              hintText: 'Enter your username',
              prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.navy, size: 20),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Username is required';
              return null;
            },
          ),
          const SizedBox(height: 16),
          const Text('Password',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.navy)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.navy, size: 20),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppTheme.textSecondary, size: 20),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Password is required';
              return null;
            },
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: AppTheme.errorLight, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_errorMessage!, style: const TextStyle(color: AppTheme.error, fontSize: 13))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _isLoading ? null : _signIn,
            child: _isLoading
                ? const SizedBox(height: 22, width: 22,
                    child: CircularProgressIndicator(color: AppTheme.white, strokeWidth: 2.5))
                : const Text('Sign In'),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text('Contact your Super Admin if you need access',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

// ─── Change Admin Password Screen ───────────────────────────────────────────

class ChangeAdminPasswordScreen extends StatefulWidget {
  final String adminDocId;
  final String adminName;
  final String email;
  const ChangeAdminPasswordScreen({
    super.key,
    required this.adminDocId,
    required this.adminName,
    required this.email,
  });

  @override
  State<ChangeAdminPasswordScreen> createState() => _ChangeAdminPasswordScreenState();
}

class _ChangeAdminPasswordScreenState extends State<ChangeAdminPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  void _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.updatePassword(_newPasswordController.text.trim());

      // Update Firestore — clear temp password flag
      await FirebaseFirestore.instance
          .collection('admins')
          .doc(widget.adminDocId)
          .update({
        'isTempPassword': false,
        'tempPasswordExpiry': null,
        'passwordChangedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdminDashboardScreen(adminName: widget.adminName),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to change password. Please try again.';
      });
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
              top: MediaQuery.of(context).padding.top + 32,
              bottom: 28, left: 24, right: 24,
            ),
            child: const Column(
              children: [
                Icon(Icons.lock_reset, size: 48, color: AppTheme.white),
                SizedBox(height: 12),
                Text('Change Password',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.white)),
                SizedBox(height: 4),
                Text('You must set a new password to continue',
                    style: TextStyle(fontSize: 13, color: Colors.white70)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange.shade700, size: 18),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Your temporary password must be changed before you can access the admin panel.',
                              style: TextStyle(fontSize: 13, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Password is required';
                        if (value.length < 6) return 'Minimum 6 characters required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Confirm Password',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please confirm your password';
                        if (value != _newPasswordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.errorLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                          : const Text('Set New Password'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 14, color: Colors.white70)),
      ],
    );
  }
}
