import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'member/dashboard_screen.dart';
import 'admin/admin_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _memberIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _memberIdController.dispose();
    super.dispose();
  }

  void _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final memberId = _memberIdController.text.trim().toUpperCase();
    if (memberId.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(memberId: memberId),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please enter a valid Member ID.';
      });
    }
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppTheme.navy),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Enter your Member ID to access your account',
                      style: TextStyle(fontSize: 15, color: AppTheme.textSecondary, height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    const Text('Member ID',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.navy)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _memberIdController,
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w600,
                        letterSpacing: 4, color: AppTheme.textPrimary,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(12),
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]')),
                      ],
                      decoration: const InputDecoration(
                        hintText: 'GBC-00123',
                        hintStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w400,
                            letterSpacing: 2, color: AppTheme.textSecondary),
                        prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.navy, size: 22),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Member ID is required';
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
                            Text(_errorMessage!,
                                style: const TextStyle(color: AppTheme.error, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signIn,
                      child: _isLoading
                          ? const SizedBox(
                              height: 22, width: 22,
                              child: CircularProgressIndicator(color: AppTheme.white, strokeWidth: 2.5),
                            )
                          : const Text('Sign In'),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Contact your church office if you need\nhelp with your Member ID',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.65),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                          );
                        },
                        child: const Text(
                          'Admin Sign In →',
                          style: TextStyle(
                            color: AppTheme.navy,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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

  Widget _buildHeader() {
    return Container(
      color: AppTheme.navy,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 32,
        bottom: 28,
        left: 24,
        right: 24,
      ),
      child: Column(
        children: [
          Container(
            width: 76, height: 76,
            decoration: BoxDecoration(
              color: AppTheme.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: const Icon(Icons.church_rounded, size: 36, color: AppTheme.navy),
          ),
          const SizedBox(height: 16),
          const Text('Grace Bible Church',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.white, letterSpacing: 0.3)),
          const SizedBox(height: 5),
          const Text('123, Mission Road, Hyderabad – 500001',
              style: TextStyle(fontSize: 13, color: Colors.white70), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}