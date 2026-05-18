import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../services/member_id_service.dart';

// ── MEMBER LIST SCREEN ──
class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});
  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    return name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(context),
          _buildSearchAndFilter(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseService.getMembers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.navy));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final allMembers = snapshot.data?.docs ?? [];
                final filtered = allMembers.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final memberId = (data['memberId'] ?? '').toString().toLowerCase();
                  final phone = (data['phone'] ?? '').toString();
                  final isActive = data['isActive'] as bool? ?? true;

                  final matchesSearch = _searchQuery.isEmpty ||
                      name.contains(_searchQuery.toLowerCase()) ||
                      memberId.contains(_searchQuery.toLowerCase()) ||
                      phone.contains(_searchQuery);

                  final matchesStatus = _filterStatus == 'All' ||
                      (_filterStatus == 'Active' && isActive) ||
                      (_filterStatus == 'Inactive' && !isActive);

                  return matchesSearch && matchesStatus;
                }).toList();

                // Stats
                final total = allMembers.length;
                final active = allMembers.where((d) => (d.data() as Map)['isActive'] == true).length;
                final inactive = total - active;

                return Column(
                  children: [
                    _buildStats(total, active, inactive),
                    Expanded(
                      child: filtered.isEmpty
                          ? _buildEmptyState()
                          : ListView.separated(
                              padding: const EdgeInsets.all(14),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final doc = filtered[index];
                                final data = doc.data() as Map<String, dynamic>;
                                return _buildMemberCard(doc.id, data);
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddMemberScreen()),
        ),
        backgroundColor: AppTheme.navy,
        icon: const Icon(Icons.person_add_outlined, color: AppTheme.white),
        label: const Text('Add Member',
            style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.w600)),
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
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.white, size: 20),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),
          const Text('Members',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.white)),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: AppTheme.navy,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search by name, member ID or phone...',
              hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: AppTheme.textSecondary),
                      onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: AppTheme.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: ['All', 'Active', 'Inactive'].map((status) {
              final isSelected = _filterStatus == status;
              return GestureDetector(
                onTap: () => setState(() => _filterStatus = status),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.white : Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(status,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                          color: isSelected ? AppTheme.navy : Colors.white70)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(int total, int active, int inactive) {
    return Container(
      color: AppTheme.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _statChip('Total', '$total', AppTheme.navy),
          const SizedBox(width: 10),
          _statChip('Active', '$active', AppTheme.success),
          const SizedBox(width: 10),
          _statChip('Inactive', '$inactive', AppTheme.error),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _buildMemberCard(String docId, Map<String, dynamic> data) {
    final isActive = data['isActive'] as bool? ?? true;
    final name = data['name'] ?? '';
    final memberId = data['memberId'] ?? '';
    final phone = data['phone'] ?? '';
    final sector = data['sector'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
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
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 3),
                Text(memberId,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 3),
                Text(phone,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                if (sector.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text('Sector: $sector',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.successLight : AppTheme.errorLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: isActive ? AppTheme.success : AppTheme.error),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showMemberOptions(docId, data),
                child: const Icon(Icons.more_vert_rounded, color: AppTheme.textSecondary, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMemberOptions(String docId, Map<String, dynamic> data) {
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
                decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(data['name'] ?? '',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.navy)),
            Text(data['memberId'] ?? '',
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 20),
            _optionTile(
              isActive ? Icons.block_outlined : Icons.check_circle_outline,
              isActive ? 'Deactivate Member' : 'Activate Member',
              isActive ? AppTheme.gold : AppTheme.success,
              () async {
                Navigator.pop(context);
                await FirebaseFirestore.instance
                    .collection('members')
                    .doc(docId)
                    .update({'isActive': !isActive});
              },
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
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: color),
      ),
      title: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color)),
      onTap: onTap,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(_searchQuery.isNotEmpty ? 'No members found for "$_searchQuery"' : 'No members yet',
              style: TextStyle(fontSize: 15, color: AppTheme.textSecondary.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}

// ── ADD MEMBER SCREEN ──
class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});
  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _sectorController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  bool _obscurePassword = true;
  String _generatedMemberId = '';
  String _submittedName = '';

  @override
  void initState() {
    super.initState();
    _loadNextMemberId();
  }

  void _loadNextMemberId() async {
    final id = await MemberIdService.generateNextMemberId();
    if (mounted) setState(() => _generatedMemberId = id);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _sectorController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      await FirebaseService.addMember(
        memberId: _generatedMemberId,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
        address: _addressController.text.trim(),
        sector: _sectorController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isSubmitted = true;
          _submittedName = _nameController.text.trim();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppTheme.error),
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
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.white, size: 20),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),
          const Text('Add New Member',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.white)),
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
            // Auto-generated Member ID
            Container(
              decoration: BoxDecoration(
                color: AppTheme.navyLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.badge_outlined, color: AppTheme.navy, size: 22),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Member ID (Auto-generated)',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      const SizedBox(height: 3),
                      Text(
                        _generatedMemberId.isEmpty ? 'Loading...' : _generatedMemberId,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                            color: AppTheme.navy, letterSpacing: 2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Form fields
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
                  _formField('Full Name *', 'Enter full name', _nameController,
                      icon: Icons.person_outline_rounded,
                      validator: (v) => v!.trim().isEmpty ? 'Name is required' : null),
                  const SizedBox(height: 14),
                  _formField('Phone Number *', '+91 00000 00000', _phoneController,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.trim().isEmpty ? 'Phone is required' : null),
                  const SizedBox(height: 14),
                  _formField('Email Address *', 'name@email.com', _emailController,
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v!.trim().isEmpty ? 'Email is required' : null),
                  const SizedBox(height: 14),
                  _formField('Address', 'Area, City', _addressController,
                      icon: Icons.location_on_outlined),
                  const SizedBox(height: 14),
                  _formField('Sector', 'e.g. North, South, Zone 1', _sectorController,
                      icon: Icons.map_outlined),
                  const SizedBox(height: 14),

                  // Password field
                  const Text('Initial Password *',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.navy)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Set initial password (min 6 chars)',
                      prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.navy, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                            color: AppTheme.textSecondary, size: 20),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Password is required';
                      if (v.length < 6) return 'Minimum 6 characters required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Share this password with the member. They can change it from their Profile.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(height: 22, width: 22,
                            child: CircularProgressIndicator(color: AppTheme.white, strokeWidth: 2.5))
                        : const Text('Create Member'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formField(String label, String hint, TextEditingController controller,
      {IconData? icon, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.navy)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, color: AppTheme.navy, size: 20) : null,
          ),
          validator: validator,
        ),
      ],
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
              decoration: const BoxDecoration(color: AppTheme.successLight, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, size: 48, color: AppTheme.success),
            ),
            const SizedBox(height: 24),
            const Text('Member Created!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.navy)),
            const SizedBox(height: 12),
            Text('$_submittedName has been added successfully.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary, height: 1.5)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppTheme.navyLight, borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Member ID: ',
                      style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                  Text(_generatedMemberId,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                          color: AppTheme.navy, letterSpacing: 2)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Members'),
            ),
          ],
        ),
      ),
    );
  }
}
