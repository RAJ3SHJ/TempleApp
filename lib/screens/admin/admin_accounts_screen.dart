import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AdminAccountsScreen extends StatefulWidget {
  const AdminAccountsScreen({super.key});

  @override
  State<AdminAccountsScreen> createState() => _AdminAccountsScreenState();
}

class AdminAccount {
  final String id;
  final String name;
  final String username;
  final String email;
  final String role;
  final String lastLogin;
  bool isActive;

  AdminAccount({
    required this.id, required this.name, required this.username,
    required this.email, required this.role, required this.lastLogin,
    this.isActive = true,
  });
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

  final List<String> _roles = ['Full Access', 'Data Entry', 'Viewer'];

  final List<AdminAccount> _admins = [
    AdminAccount(id: '1', name: 'Alex Jacob', username: 'alex.jacob',
        email: 'alex@gracebible.org', role: 'Data Entry', lastLogin: '2 hours ago'),
    AdminAccount(id: '2', name: 'Sarah Mathew', username: 'sarah.mathew',
        email: 'sarah@gracebible.org', role: 'Full Access', lastLogin: '4 hours ago'),
    AdminAccount(id: '3', name: 'Raju Kurian', username: 'raju.kurian',
        email: 'raju@gracebible.org', role: 'Data Entry', lastLogin: '2 days ago'),
    AdminAccount(id: '4', name: 'Meena Thomas', username: 'meena.thomas',
        email: 'meena@gracebible.org', role: 'Viewer', lastLogin: '1 week ago', isActive: false),
  ];

  String _getInitials(String name) => name.split(' ').map((e) => e[0]).take(2).join().toUpperCase();

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
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _admins.add(AdminAccount(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        role: _selectedRole, lastLogin: 'Never',
      ));
      _isSubmitting = false;
      _showAddForm = false;
      _nameController.clear();
      _usernameController.clear();
      _emailController.clear();
      _passwordController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Admin account created!'), backgroundColor: AppTheme.success),
    );
  }

  void _showAdminOptions(AdminAccount admin) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(admin.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.navy)),
            Text(admin.username, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 20),
            _optionTile(Icons.key_outlined, 'Change Role', AppTheme.navy, () {
              Navigator.pop(context);
              _showChangeRole(admin);
            }),
            _optionTile(
              admin.isActive ? Icons.block_outlined : Icons.check_circle_outline,
              admin.isActive ? 'Deactivate Admin' : 'Activate Admin',
              admin.isActive ? AppTheme.gold : AppTheme.success,
              () { setState(() => admin.isActive = !admin.isActive); Navigator.pop(context); },
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
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: color),
      ),
      title: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color)),
      onTap: onTap,
    );
  }

  void _showChangeRole(AdminAccount admin) {
    String selectedRole = admin.role;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Change Role — ${admin.name}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.navy)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _roles.map((role) => RadioListTile<String>(
              title: Text(role), value: role, groupValue: selectedRole,
              activeColor: AppTheme.navy,
              onChanged: (value) => setDialogState(() => selectedRole = value!),
            )).toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary))),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  final index = _admins.indexWhere((a) => a.id == admin.id);
                  if (index != -1) {
                    _admins[index] = AdminAccount(
                      id: admin.id, name: admin.name, username: admin.username,
                      email: admin.email, role: selectedRole,
                      lastLogin: admin.lastLogin, isActive: admin.isActive,
                    );
                  }
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(AdminAccount admin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Admin Account'),
        content: Text('Are you sure you want to delete ${admin.name}\'s admin account?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary))),
          ElevatedButton(
            onPressed: () {
              setState(() => _admins.removeWhere((a) => a.id == admin.id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error,
                minimumSize: const Size(80, 38),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Delete'),
          ),
        ],
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _buildStats(),
                  const SizedBox(height: 12),
                  _buildAdminList(),
                  const SizedBox(height: 12),
                  if (_showAddForm) _buildAddAdminForm(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => setState(() => _showAddForm = !_showAddForm),
        backgroundColor: AppTheme.navy,
        icon: Icon(_showAddForm ? Icons.close : Icons.person_add_outlined, color: AppTheme.white),
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
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.white, size: 20),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),
          const Text('Admin Accounts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.white)),
          const Spacer(),
          Text('${_admins.length} admins', style: const TextStyle(fontSize: 13, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final active = _admins.where((a) => a.isActive).length;
    final inactive = _admins.where((a) => !a.isActive).length;
    return Row(
      children: [
        Expanded(child: _statCard('Total', '${_admins.length}', AppTheme.navy)),
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
      decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ]),
    );
  }

  Widget _buildAdminList() {
    return Container(
      decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
      child: Column(
        children: _admins.asMap().entries.map((entry) {
          final isLast = entry.key == _admins.length - 1;
          final admin = entry.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: admin.isActive ? AppTheme.navyLight : AppTheme.border,
                      child: Text(_getInitials(admin.name),
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                              color: admin.isActive ? AppTheme.navy : AppTheme.textSecondary)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(admin.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                        Text(admin.username, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        const SizedBox(height: 4),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: _getRoleBgColor(admin.role), borderRadius: BorderRadius.circular(20)),
                            child: Text(admin.role, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _getRoleColor(admin.role))),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: admin.isActive ? AppTheme.successLight : AppTheme.errorLight, borderRadius: BorderRadius.circular(20)),
                            child: Text(admin.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                    color: admin.isActive ? AppTheme.success : AppTheme.error)),
                          ),
                        ]),
                        Text('Last login: ${admin.lastLogin}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      ]),
                    ),
                    IconButton(
                      onPressed: () => _showAdminOptions(admin),
                      icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textSecondary, size: 20),
                    ),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1, indent: 14, endIndent: 14, color: AppTheme.border),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAddAdminForm() {
    return Container(
      decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.navy, width: 1.5)),
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.person_add_outlined, size: 18, color: AppTheme.navy),
            SizedBox(width: 8),
            Text('New Admin Account', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.navy)),
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
          _formField('Password', 'Set a password', _passwordController,
              obscureText: true,
              validator: (v) => v!.trim().length < 6 ? 'Min 6 characters' : null),
          const SizedBox(height: 14),
          const Text('Role', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.navy)),
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
                    child: CircularProgressIndicator(color: AppTheme.white, strokeWidth: 2.5))
                : const Text('Create Admin Account'),
          ),
        ]),
      ),
    );
  }

  Widget _formField(String label, String hint, TextEditingController controller,
      {TextInputType? keyboardType, bool obscureText = false, String? Function(String?)? validator}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.navy)),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller, keyboardType: keyboardType, obscureText: obscureText,
        decoration: InputDecoration(hintText: hint),
        validator: validator,
      ),
    ]);
  }
}