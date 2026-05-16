import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'admin_dashboard_screen.dart';

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
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    if (username.isNotEmpty && password.isNotEmpty) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => AdminDashboardScreen(adminName: username)));
    } else {
      setState(() { _isLoading = false; _errorMessage = 'Invalid username or password.'; });
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
                  const SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        _FeatureItem(icon: Icons.people_outline, text: 'Manage Members'),
                        SizedBox(height: 12),
                        _FeatureItem(icon: Icons.receipt_long_outlined, text: 'Track Donations'),
                        SizedBox(height: 12),
                        _FeatureItem(icon: Icons.bar_chart_outlined, text: 'View Reports'),
                        SizedBox(height: 12),
                        _FeatureItem(icon: Icons.shield_outlined, text: 'Role Based Access'),
                      ],
                    ),
                  ),
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
                  Text(_errorMessage!, style: const TextStyle(color: AppTheme.error, fontSize: 13)),
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
