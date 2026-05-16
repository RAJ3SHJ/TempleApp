import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class DonationCategory {
  final String id;
  final String name;
  final bool isDefault;
  int usageCount;

  DonationCategory({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.usageCount,
  });
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final _newCategoryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<DonationCategory> _categories = [
    DonationCategory(id: '1', name: 'Tithe', isDefault: true, usageCount: 1240),
    DonationCategory(id: '2', name: 'Offering', isDefault: true, usageCount: 890),
    DonationCategory(id: '3', name: 'Building Fund', isDefault: true, usageCount: 450),
    DonationCategory(id: '4', name: 'Special Fund', isDefault: false, usageCount: 230),
    DonationCategory(id: '5', name: 'Charity Drive', isDefault: false, usageCount: 120),
    DonationCategory(id: '6', name: 'Missions', isDefault: false, usageCount: 85),
  ];

  List<DonationCategory> get _defaultCategories =>
      _categories.where((c) => c.isDefault).toList();

  List<DonationCategory> get _customCategories =>
      _categories.where((c) => !c.isDefault).toList();

  void _addCategory() {
    if (!_formKey.currentState!.validate()) return;
    final name = _newCategoryController.text.trim();
    final exists = _categories.any((c) => c.name.toLowerCase() == name.toLowerCase());
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category already exists!')),
      );
      return;
    }
    setState(() {
      _categories.add(DonationCategory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        isDefault: false,
        usageCount: 0,
      ));
      _newCategoryController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Category "$name" added successfully!'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _deleteCategory(DonationCategory category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Category',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        content: Text(
          'Are you sure you want to delete "${category.name}"?\n\nThis category has been used ${category.usageCount} times.',
          style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _categories.removeWhere((c) => c.id == category.id));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Category "${category.name}" deleted.'),
                  backgroundColor: AppTheme.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              minimumSize: const Size(80, 38),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editCategory(DonationCategory category) {
    final controller = TextEditingController(text: category.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Category',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.navy)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Category name',
            filled: true,
            fillColor: AppTheme.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.navy, width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                setState(() {
                  final index = _categories.indexWhere((c) => c.id == category.id);
                  if (index != -1) {
                    _categories[index] = DonationCategory(
                      id: category.id,
                      name: newName,
                      isDefault: category.isDefault,
                      usageCount: category.usageCount,
                    );
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Category updated to "$newName"'),
                    backgroundColor: AppTheme.success,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
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
                  _buildDefaultCategories(),
                  const SizedBox(height: 12),
                  _buildCustomCategories(),
                  const SizedBox(height: 12),
                  _buildAddCategory(),
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
          const Text('Category Management',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.white)),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Categories',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 4),
                Text('${_categories.length}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.navy)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Custom Categories',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 4),
                Text('${_customCategories.length}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.navy)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultCategories() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lock_outline_rounded, size: 18, color: AppTheme.navy),
              SizedBox(width: 8),
              Text('Default Categories',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.navy)),
            ],
          ),
          const SizedBox(height: 4),
          const Text('These are system categories and cannot be deleted.',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.border),
          ..._defaultCategories.map((category) => _buildCategoryTile(category)),
        ],
      ),
    );
  }

  Widget _buildCustomCategories() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tag_outlined, size: 18, color: AppTheme.navy),
              SizedBox(width: 8),
              Text('Custom Categories',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.navy)),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Custom categories can be edited or deleted.',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.border),
          if (_customCategories.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('No custom categories yet.\nAdd one below!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6)),
              ),
            )
          else
            ..._customCategories.map((category) => _buildCategoryTile(category, isCustom: true)),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(DonationCategory category, {bool isCustom = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCustom ? const Color(0xFFFEF3C7) : AppTheme.navyLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isCustom ? Icons.tag_outlined : Icons.lock_outline_rounded,
                  size: 18,
                  color: isCustom ? AppTheme.gold : AppTheme.navy,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                    Text('Used ${category.usageCount} times',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              if (isCustom) ...[
                IconButton(
                  onPressed: () => _editCategory(category),
                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.navy),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _deleteCategory(category),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.error),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ] else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.navyLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Default',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.navy)),
                ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppTheme.border),
      ],
    );
  }

  Widget _buildAddCategory() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.add_circle_outline_rounded, size: 18, color: AppTheme.navy),
                SizedBox(width: 8),
                Text('Add Custom Category',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.navy)),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppTheme.border),
            const SizedBox(height: 12),
            const Text('Category Name',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.navy)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _newCategoryController,
              decoration: const InputDecoration(
                hintText: 'Enter category name...',
                prefixIcon: Icon(Icons.tag_outlined, color: AppTheme.navy, size: 20),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Category name is required';
                if (v.trim().length < 3) return 'Name must be at least 3 characters';
                return null;
              },
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: _addCategory,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Category'),
            ),
          ],
        ),
      ),
    );
  }
}