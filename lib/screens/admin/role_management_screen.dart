import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RoleManagementScreen extends StatefulWidget {
  const RoleManagementScreen({super.key});

  @override
  State<RoleManagementScreen> createState() => _RoleManagementScreenState();
}

class Permission {
  final String id;
  final String label;
  final String group;
  bool isEnabled;

  Permission({
    required this.id,
    required this.label,
    required this.group,
    this.isEnabled = false,
  });
}

class AdminRole {
  final String id;
  String name;
  final bool isDefault;
  int adminCount;
  List<Permission> permissions;

  AdminRole({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.adminCount,
    required this.permissions,
  });
}

class _RoleManagementScreenState extends State<RoleManagementScreen> {
  final _newRoleController = TextEditingController();

  List<Permission> _defaultPermissions({bool fullAccess = false}) {
    return [
      Permission(id: 'view_members', label: 'View Members', group: 'Member Management', isEnabled: fullAccess || true),
      Permission(id: 'add_member', label: 'Add Member', group: 'Member Management', isEnabled: fullAccess),
      Permission(id: 'edit_member', label: 'Edit Member', group: 'Member Management', isEnabled: fullAccess),
      Permission(id: 'deactivate_member', label: 'Deactivate Member', group: 'Member Management', isEnabled: fullAccess),
      Permission(id: 'view_donations', label: 'View Donations', group: 'Donation Management', isEnabled: fullAccess || true),
      Permission(id: 'add_donation', label: 'Add Donation', group: 'Donation Management', isEnabled: fullAccess),
      Permission(id: 'edit_donation', label: 'Edit Donation', group: 'Donation Management', isEnabled: fullAccess),
      Permission(id: 'delete_donation', label: 'Delete Donation', group: 'Donation Management', isEnabled: fullAccess),
      Permission(id: 'search_filter', label: 'Search & Filter', group: 'Other Access', isEnabled: fullAccess || true),
      Permission(id: 'category_management', label: 'Category Management', group: 'Other Access', isEnabled: fullAccess),
      Permission(id: 'view_audit', label: 'View Audit Trail', group: 'Other Access', isEnabled: fullAccess),
    ];
  }

  late List<AdminRole> _roles;

  @override
  void initState() {
    super.initState();
    _roles = [
      AdminRole(
        id: '1', name: 'Full Access', isDefault: true, adminCount: 2,
        permissions: _defaultPermissions(fullAccess: true),
      ),
      AdminRole(
        id: '2', name: 'Data Entry', isDefault: true, adminCount: 3,
        permissions: _defaultPermissions()..forEach((p) {
          if (['add_donation', 'view_members', 'view_donations', 'search_filter'].contains(p.id)) {
            p.isEnabled = true;
          }
        }),
      ),
      AdminRole(
        id: '3', name: 'Viewer', isDefault: true, adminCount: 1,
        permissions: _defaultPermissions()..forEach((p) {
          if (['view_members', 'view_donations', 'search_filter'].contains(p.id)) {
            p.isEnabled = true;
          }
        }),
      ),
    ];
  }

  @override
  void dispose() {
    _newRoleController.dispose();
    super.dispose();
  }

  void _addRole() {
    final name = _newRoleController.text.trim();
    if (name.isEmpty) return;
    final exists = _roles.any((r) => r.name.toLowerCase() == name.toLowerCase());
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Role already exists!')),
      );
      return;
    }
    setState(() {
      _roles.add(AdminRole(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name, isDefault: false, adminCount: 0,
        permissions: _defaultPermissions(),
      ));
      _newRoleController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Role "$name" created!'), backgroundColor: AppTheme.success),
    );
  }

  void _openPermissions(AdminRole role) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RolePermissionsScreen(role: role, onSave: () => setState(() {}))),
    );
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
                  _buildRoleList(),
                  const SizedBox(height: 12),
                  _buildAddRole(),
                  const SizedBox(height: 20),
                ],
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
          const Text('Role Management',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.white)),
          const Spacer(),
          Text('${_roles.length} roles', style: const TextStyle(fontSize: 13, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final totalAdmins = _roles.fold(0, (sum, r) => sum + r.adminCount);
    return Row(
      children: [
        Expanded(child: _statCard('Total Roles', '${_roles.length}', AppTheme.navy)),
        const SizedBox(width: 10),
        Expanded(child: _statCard('Total Admins', '$totalAdmins', AppTheme.navyMid)),
        const SizedBox(width: 10),
        Expanded(child: _statCard('Custom Roles', '${_roles.where((r) => !r.isDefault).length}', AppTheme.gold)),
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

  Widget _buildRoleList() {
    return Container(
      decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
      child: Column(
        children: _roles.asMap().entries.map((entry) {
          final isLast = entry.key == _roles.length - 1;
          final role = entry.value;
          final enabledCount = role.permissions.where((p) => p.isEnabled).length;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: role.isDefault ? AppTheme.navyLight : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        role.isDefault ? Icons.lock_outline_rounded : Icons.key_outlined,
                        size: 20,
                        color: role.isDefault ? AppTheme.navy : AppTheme.gold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text(role.name,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                          const SizedBox(width: 8),
                          if (role.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(color: AppTheme.navyLight, borderRadius: BorderRadius.circular(20)),
                              child: const Text('Default', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.navy)),
                            ),
                        ]),
                        Text('${role.adminCount} admins assigned · $enabledCount permissions enabled',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      ]),
                    ),
                    GestureDetector(
                      onTap: () => _openPermissions(role),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppTheme.navyLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.tune_outlined, size: 14, color: AppTheme.navy),
                            SizedBox(width: 4),
                            Text('Permissions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.navy)),
                          ],
                        ),
                      ),
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

  Widget _buildAddRole() {
    return Container(
      decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.add_circle_outline_rounded, size: 18, color: AppTheme.navy),
          SizedBox(width: 8),
          Text('Create New Role', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.navy)),
        ]),
        const SizedBox(height: 12),
        const Divider(height: 1, color: AppTheme.border),
        const SizedBox(height: 12),
        const Text('Role Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.navy)),
        const SizedBox(height: 8),
        TextField(
          controller: _newRoleController,
          decoration: const InputDecoration(
            hintText: 'e.g. Finance Manager',
            prefixIcon: Icon(Icons.key_outlined, color: AppTheme.navy, size: 20),
          ),
        ),
        const SizedBox(height: 14),
        ElevatedButton.icon(
          onPressed: _addRole,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Create Role'),
        ),
      ]),
    );
  }
}

// ── ROLE PERMISSIONS SCREEN ──
class RolePermissionsScreen extends StatefulWidget {
  final AdminRole role;
  final VoidCallback onSave;

  const RolePermissionsScreen({super.key, required this.role, required this.onSave});

  @override
  State<RolePermissionsScreen> createState() => _RolePermissionsScreenState();
}

class _RolePermissionsScreenState extends State<RolePermissionsScreen> {
  late List<Permission> _permissions;

  @override
  void initState() {
    super.initState();
    _permissions = widget.role.permissions;
  }

  Map<String, List<Permission>> get _groupedPermissions {
    final Map<String, List<Permission>> grouped = {};
    for (final p in _permissions) {
      grouped.putIfAbsent(p.group, () => []).add(p);
    }
    return grouped;
  }

  void _savePermissions() {
    widget.onSave();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Permissions saved for "${widget.role.name}"'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enabledCount = _permissions.where((p) => p.isEnabled).length;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Header
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
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.role.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.white)),
                    Text('$enabledCount of ${_permissions.length} permissions enabled',
                        style: const TextStyle(fontSize: 12, color: Colors.white70)),
                  ]),
                ),
              ],
            ),
          ),

          // Permissions list
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  // Enable All / Disable All
                  Container(
                    decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Text('Quick Select', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.navy)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => setState(() { for (var p in _permissions) p.isEnabled = true; }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: AppTheme.navyLight, borderRadius: BorderRadius.circular(8)),
                            child: const Text('Enable All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.navy)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() { for (var p in _permissions) p.isEnabled = false; }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: AppTheme.errorLight, borderRadius: BorderRadius.circular(8)),
                            child: const Text('Disable All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.error)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Grouped permissions
                  ..._groupedPermissions.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(entry.key.toUpperCase(),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary, letterSpacing: 0.8)),
                        ),
                        Container(
                          decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
                          child: Column(
                            children: entry.value.asMap().entries.map((pEntry) {
                              final isLast = pEntry.key == entry.value.length - 1;
                              final permission = pEntry.value;
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                            Text(permission.label,
                                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                                            Text(permission.isEnabled ? 'Enabled' : 'Disabled',
                                                style: TextStyle(fontSize: 12,
                                                    color: permission.isEnabled ? AppTheme.success : AppTheme.textSecondary)),
                                          ]),
                                        ),
                                        GestureDetector(
                                          onTap: () => setState(() => permission.isEnabled = !permission.isEnabled),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            width: 50, height: 28,
                                            decoration: BoxDecoration(
                                              color: permission.isEnabled ? AppTheme.navy : const Color(0xFFD1D5DB),
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            child: AnimatedAlign(
                                              duration: const Duration(milliseconds: 200),
                                              alignment: permission.isEnabled ? Alignment.centerRight : Alignment.centerLeft,
                                              child: Container(
                                                width: 22, height: 22,
                                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                                                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16, color: AppTheme.border),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }),

                  // Save button
                  ElevatedButton(
                    onPressed: _savePermissions,
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.save_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Save Permissions'),
                    ]),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}