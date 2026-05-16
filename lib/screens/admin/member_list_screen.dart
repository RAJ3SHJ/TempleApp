import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

// Member Model
class Member {
  final String id;
  final String memberId;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String joinedDate;
  bool isActive;

  Member({
    required this.id,
    required this.memberId,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.joinedDate,
    this.isActive = true,
  });
}

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

  final List<Member> _members = [
    Member(id: '1', memberId: 'GBC-00123', name: 'John Samuel', phone: '+91 98765 00123',
        email: 'john.samuel@email.com', address: 'Banjara Hills, Hyderabad', joinedDate: 'Jan 2019'),
    Member(id: '2', memberId: 'GBC-00124', name: 'Priya Mathew', phone: '+91 98765 00124',
        email: 'priya.mathew@email.com', address: 'Jubilee Hills, Hyderabad', joinedDate: 'Mar 2019'),
    Member(id: '3', memberId: 'GBC-00125', name: 'Thomas Jacob', phone: '+91 98765 00125',
        email: 'thomas.jacob@email.com', address: 'Secunderabad, Hyderabad', joinedDate: 'Jun 2019'),
    Member(id: '4', memberId: 'GBC-00126', name: 'Anu Kurian', phone: '+91 98765 00126',
        email: 'anu.kurian@email.com', address: 'Gachibowli, Hyderabad', joinedDate: 'Aug 2019',
        isActive: false),
    Member(id: '5', memberId: 'GBC-00127', name: 'Suresh Philip', phone: '+91 98765 00127',
        email: 'suresh.philip@email.com', address: 'Madhapur, Hyderabad', joinedDate: 'Nov 2019'),
    Member(id: '6', memberId: 'GBC-00128', name: 'Meena Thomas', phone: '+91 98765 00128',
        email: 'meena.thomas@email.com', address: 'Kukatpally, Hyderabad', joinedDate: 'Jan 2020'),
    Member(id: '7', memberId: 'GBC-00129', name: 'Rajan George', phone: '+91 98765 00129',
        email: 'rajan.george@email.com', address: 'LB Nagar, Hyderabad', joinedDate: 'Feb 2020',
        isActive: false),
    Member(id: '8', memberId: 'GBC-00130', name: 'Sonia Abraham', phone: '+91 98765 00130',
        email: 'sonia.abraham@email.com', address: 'Dilsukhnagar, Hyderabad', joinedDate: 'Apr 2020'),
  ];

  List<Member> get _filteredMembers {
    return _members.where((m) {
      final matchesSearch = _searchQuery.isEmpty ||
          m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.memberId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.phone.contains(_searchQuery);
      final matchesStatus = _filterStatus == 'All' ||
          (_filterStatus == 'Active' && m.isActive) ||
          (_filterStatus == 'Inactive' && !m.isActive);
      return matchesSearch && matchesStatus;
    }).toList();
  }

  String _getInitials(String name) {
    return name.split(' ').map((e) => e[0]).take(2).join().toUpperCase();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(context),
          _buildSearchAndFilter(),
          _buildStats(),
          Expanded(
            child: _filteredMembers.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(14),
                    itemCount: _filteredMembers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) =>
                        _buildMemberCard(_filteredMembers[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMemberScreen()),
          );
          setState(() {});
        },
        backgroundColor: AppTheme.navy,
        icon: const Icon(Icons.person_add_outlined, color: AppTheme.white),
        label: const Text('Add Member', style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.w600)),
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
          const Spacer(),
          Text('${_members.length} total',
              style: const TextStyle(fontSize: 13, color: Colors.white70)),
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
          // Search bar
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
          // Filter tabs
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
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500,
                          color: isSelected ? AppTheme.navy : Colors.white70)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final active = _members.where((m) => m.isActive).length;
    final inactive = _members.where((m) => !m.isActive).length;
    return Container(
      color: AppTheme.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _statChip('Total', '${_members.length}', AppTheme.navy),
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
        color: color.withOpacity(0.1),
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

  Widget _buildMemberCard(Member member) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: member.isActive ? AppTheme.navyLight : AppTheme.border,
            child: Text(_getInitials(member.name),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                    color: member.isActive ? AppTheme.navy : AppTheme.textSecondary)),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                const SizedBox(height: 3),
                Text(member.memberId,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 3),
                Text(member.phone,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          // Status & actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: member.isActive ? AppTheme.successLight : AppTheme.errorLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  member.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: member.isActive ? AppTheme.success : AppTheme.error),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showMemberOptions(member),
                    child: const Icon(Icons.more_vert_rounded, color: AppTheme.textSecondary, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMemberOptions(Member member) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(
                color: AppTheme.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(member.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.navy)),
            Text(member.memberId,
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 20),
            _optionTile(Icons.edit_outlined, 'Edit Member', AppTheme.navy, () {
              Navigator.pop(context);
            }),
            _optionTile(
              member.isActive ? Icons.block_outlined : Icons.check_circle_outline,
              member.isActive ? 'Deactivate Member' : 'Activate Member',
              member.isActive ? AppTheme.gold : AppTheme.success,
              () {
                setState(() => member.isActive = !member.isActive);
                Navigator.pop(context);
              },
            ),
            _optionTile(Icons.delete_outline_rounded, 'Delete Member', AppTheme.error, () {
              Navigator.pop(context);
              _showDeleteConfirm(member);
            }),
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
            color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: color),
      ),
      title: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color)),
      onTap: onTap,
    );
  }

  void _showDeleteConfirm(Member member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Member'),
        content: Text('Are you sure you want to delete ${member.name}? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary))),
          ElevatedButton(
            onPressed: () {
              setState(() => _members.removeWhere((m) => m.id == member.id));
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppTheme.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(_searchQuery.isNotEmpty ? 'No members found for "$_searchQuery"' : 'No members yet',
              style: TextStyle(fontSize: 15, color: AppTheme.textSecondary.withOpacity(0.6))),
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
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  String _generatedMemberId = 'GBC-00248';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() { _isSubmitting = false; _isSubmitted = true; });
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
                      Text(_generatedMemberId,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                              color: AppTheme.navy, letterSpacing: 2)),
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
                  _formField('Full Name', 'Enter full name', _nameController,
                      icon: Icons.person_outline_rounded,
                      validator: (v) => v!.trim().isEmpty ? 'Name is required' : null),
                  const SizedBox(height: 14),
                  _formField('Phone Number', '+91 00000 00000', _phoneController,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.trim().isEmpty ? 'Phone is required' : null),
                  const SizedBox(height: 14),
                  _formField('Email Address', 'name@email.com', _emailController,
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 14),
                  _formField('Address', 'Area, City', _addressController,
                      icon: Icons.location_on_outlined),
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
            Text('${_nameController.text} has been added successfully.',
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