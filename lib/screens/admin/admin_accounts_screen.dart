import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';

class AdminAccountsScreen extends StatefulWidget {
  const AdminAccountsScreen({super.key});
  @override
  State<AdminAccountsScreen> createState() => _AdminAccountsScreenState();
}

class _AdminAccountsScreenState extends State<AdminAccountsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'Data Entry';
  bool _showAddForm = false;
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  final List<String> _roles = ['Full Access', 'Data Entry', 'Viewer'];

  String _getInitials(String name) =>
      name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Full Access': return AppTheme.navy;
      case 'Data Entry': return AppTheme.navyMid;
      case 'Viewer': return AppTheme.gold;
      default: return AppTheme.navy;
    }
  }

  Color _getRoleBgColor(String role) {
    switch (role) {
      case 'Full Access': return AppTheme.navyLight;
      case 'Data Entry': return const Color(0xFFEEF2FF);
      case 'Viewer': return const Color(0xFFFEF3C7);
      default: return AppTheme.navyLight;
    }
  }

  void _addAdmin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await FirebaseService.addAdmin(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        tempPassword: _passwordController.text.trim(),
        role: _selectedRole.toLowerCase().replaceAll(' ', '_'),
      );
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _showAddForm = false;
          _nameController.clear();
          _usernameController.clear();
          _emailController.clear();
          _passwordController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin account created!'),
              backgroundColor: AppTheme.success),
        );
      }
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

  void _showAdminOptions(String docId, Map<String, dynamic> data) {
    final isActive = data['isActive'] as bool? ?? true;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(data['name'] ?? '',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                    color: AppTheme.navy)),
            Text(data['username'] ?? '',
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 20),

            // Reset Password
            _optionTile(Icons.lock_reset, 'Reset Password', AppTheme.navy, () {
              Navigator.pop(context);
              _showResetPasswordDialog(docId, data);
            }),

            // Activate/Deactivate
            _optionTile(
              isActive ? Icons.block_outlined : Icons.check_circle_outline,
              isActive ? 'Deactivate Admin' : 'Activate Admin',
              isActive ? AppTheme.gold : AppTheme.success,
              () async {
                Navigator.pop(context);
                await FirebaseFirestore.instance
                    .collection('admins')
                    .doc(docId)
                    .update({'isActive': !isActive});
              },
            ),

            // Change Role
            _optionTile(Icons.key_outlined, 'Change Role', AppTheme.navyMid, () {
              Navigator.pop(context);
              _showChangeRole(docId, data);
            }),
          ],
        ),
      ),
    );
  }

  void _showResetPasswordDialog(String docId, Map<String, dynamic> data) {
    final tempPasswordController = TextEditingController();
    final resetFormKey = GlobalKey<FormState>();
    bool isResetting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock_reset, color: AppTheme.navy, size: 28),
              const SizedBox(height: 8),
              Text('Reset Password — ${data['name']}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                      color: AppTheme.navy)),
            ],
          ),
          content: Form(
            key: resetFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Text(
                    'A temporary password will be set. Admin must change it on next login. It expires in 24 hours.',
                    style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('New Temporary Password',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: AppTheme.navy)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: tempPasswordController,
                  decoration: const InputDecoration(
                    hintText: 'Min 6 characters',
                    prefixIcon: Icon(Icons.lock_outline, color: AppTheme.navy, size: 20),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: isResetting ? null : () async {
                if (!resetFormKey.currentState!.validate()) return;
                setDialogState(() => isResetting = true);
                try {
                  await FirebaseFirestore.instance
                      .collection('admins')
                      .doc(docId)
                      .update({
                    'isTempPassword': true,
                    'tempPasswordExpiry': Timestamp.fromDate(
                      DateTime.now().add(const Duration(hours: 24)),
                    ),
                    'passwordResetAt': FieldValue.serverTimestamp(),
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset! Share the new temp password with admin.'),
                        backgroundColor: AppTheme.success,
                      ),
                    );
                  }
                } catch (e) {
                  setDialogState(() => isResetting = false);
                }
              },
              child: isResetting
                  ? const SizedBox(height: 18, width: 18,
                      child: CircularProgressIndicator(color: AppTheme.white, strokeWidth: 2))
                  : const Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionTile(IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: color),
      ),
      title: Text(label,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color)),
      onTap: onTap,
    );
  }

  void _showChangeRole(String docId, Map<String, dynamic> data) {
    String selectedRole = data['role'] as String? ?? 'Data Entry';
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Change Role — ${data['name']}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                  color: AppTheme.navy)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _roles.map((role) => RadioListTile<String>(
              title: Text(role),
              value: role,
              groupValue: selectedRole,
              activeColor: AppTheme.navy,
              onChanged: (value) => setDialogState(() => selectedRole = value!),
            )).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('admins')
                    .doc(docId)
                    .update({'role': selectedRole});
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('admins')
                  .orderBy('name')
                  .snapshots(),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                final active = docs.where((d) =>
                    (d.data() as Map)['isActive'] == true).length;
                final inactive = docs.length - active;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      _buildStats(docs.length, active, inactive),
                      const SizedBox(height: 12),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Center(child: CircularProgressIndicator(color: AppTheme.navy))
                      else if (docs.isEmpty)
                        _buildEmptyState()
                      else
                        _buildAdminList(docs),
                      const SizedBox(height: 12),
                      if (_showAddForm) _buildAddAdminForm(),
                      const SizedBox(height: 80),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => setState(() => _showAddForm = !_showAddForm),
        backgroundColor: AppTheme.navy,
        icon: Icon(_showAddForm ? Icons.close : Icons.person_add_outlined,
            color: AppTheme.white),
        label: Text(_showAddForm ? 'Cancel' : 'Add Admin',
            style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w600)),
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
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppTheme.white, size: 20),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),
          const Text('Admin Accounts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                  color: AppTheme.white)),
        ],
      ),
    );
  }

  Widget _buildStats(int total, int active, int inactive) {
    return Row(
      children: [
        Expanded(child: _statCard('Total', '$total', AppTheme.navy)),
        const SizedBox(width: 10),
        Expanded(child: _statCard('Active', '$active', AppTheme.success)),
        const SizedBox(width: 10),
        Expanded(child: _statCard('Inactive', '$inactive', AppTheme.error)),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ]),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Center(
        child: Text('No admin accounts yet. Add one below.',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
      ),
    );
  }

  Widget _buildAdminList(List<QueryDocumentSnapshot> docs) {
    return Container(
      decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border)),
      child: Column(
        children: docs.asMap().entries.map((entry) {
          final isLast = entry.key == docs.length - 1;
          final doc = entry.value;
          final data = doc.data() as Map<String, dynamic>;
          final isActive = data['isActive'] as bool? ?? true;
          final isTempPassword = data['isTempPassword'] as bool? ?? false;
          final name = data['name'] as String? ?? '';
          final username = data['username'] as String? ?? '';
          final role = data['role'] as String? ?? 'admin';

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: isActive ? AppTheme.navyLight : AppTheme.border,
                      child: Text(_getInitials(name),
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                              color: isActive ? AppTheme.navy : AppTheme.textSecondary)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary)),
                            Text(username,
                                style: const TextStyle(fontSize: 12,
                                    color: AppTheme.textSecondary)),
                            const SizedBox(height: 4),
                            Row(children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                    color: _getRoleBgColor(role),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text(role,
                                    style: TextStyle(fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _getRoleColor(role))),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                    color: isActive
                                        ? AppTheme.successLight
                                        : AppTheme.errorLight,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text(isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isActive
                                            ? AppTheme.success
                                            : AppTheme.error)),
                              ),
                              if (isTempPassword) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Text('Temp PW',
                                      style: TextStyle(fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.orange.shade700)),
                                ),
                              ],
                            ]),
                          ]),
                    ),
                    IconButton(
                      onPressed: () => _showAdminOptions(doc.id, data),
                      icon: const Icon(Icons.more_vert_rounded,
                          color: AppTheme.textSecondary, size: 20),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(height: 1, indent: 14, endIndent: 14,
                    color: AppTheme.border),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAddAdminForm() {
    return Container(
      decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.navy, width: 1.5)),
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.person_add_outlined, size: 18, color: AppTheme.navy),
            SizedBox(width: 8),
            Text('New Admin Account',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                    color: AppTheme.navy)),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.border),
          const SizedBox(height: 12),
          _formField('Full Name', 'Enter full name', _nameController,
              validator: (v) => v!.trim().isEmpty ? 'Name is required' : null),
          const SizedBox(height: 12),
          _formField('Username', 'e.g. john.doe', _usernameController,
              validator: (v) => v!.trim().isEmpty ? 'Username is required' : null),
          const SizedBox(height: 12),
          _formField('Email', 'name@gracebible.org', _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v!.trim().isEmpty ? 'Email is required' : null),
          const SizedBox(height: 12),
          const Text('Temporary Password',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: AppTheme.navy)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Min 6 characters — expires in 24hrs',
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                    color: AppTheme.textSecondary, size: 20),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) =>
            v!.trim().length < 6 ? 'Min 6 characters' : null,
          ),
          const SizedBox(height: 6),
          const Text(
            'Admin must change this password on first login.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 14),
          const Text('Role',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: AppTheme.navy)),
          const SizedBox(height: 8),
          Row(
            children: _roles.map((role) {
              final isSelected = _selectedRole == role;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRole = role),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.navy : AppTheme.navyLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(role, textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
                            color: isSelected ? AppTheme.white : AppTheme.navy)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _addAdmin,
            child: _isSubmitting
                ? const SizedBox(height: 22, width: 22,
                child: CircularProgressIndicator(
                    color: AppTheme.white, strokeWidth: 2.5))
                : const Text('Create Admin Account'),
          ),
        ]),
      ),
    );
  }

  Widget _formField(String label, String hint, TextEditingController controller,
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
              color: AppTheme.navy)),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(hintText: hint),
        validator: validator,
      ),
    ]);
  }
}
