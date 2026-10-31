import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Admin / Super Admin screen to manage Events and Announcements.
/// Members see the same data (read-only) on their Events screen.
class AdminEventsScreen extends StatefulWidget {
  /// 0 = Events tab, 1 = Announcements tab
  final int initialTab;
  const AdminEventsScreen({super.key, this.initialTab = 0});

  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _db = FirebaseFirestore.instance;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(
        length: 2, vsync: this, initialIndex: widget.initialTab.clamp(0, 1));
    _tab.addListener(() {
      if (!_tab.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final ap = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.day} ${_months[d.month - 1]} ${d.year} · $h:$m $ap';
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppTheme.error : AppTheme.success,
    ));
  }

  // ───────────────────────── EVENT FORM ─────────────────────────

  Future<void> _openEventForm({DocumentSnapshot? doc}) async {
    final data = (doc?.data() as Map<String, dynamic>?) ?? {};
    final title = TextEditingController(text: data['title'] as String? ?? '');
    final desc =
        TextEditingController(text: data['description'] as String? ?? '');
    final loc = TextEditingController(text: data['location'] as String? ?? '');
    DateTime? when = (data['date'] as Timestamp?)?.toDate();
    final formKey = GlobalKey<FormState>();
    String? dateError;
    bool saving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocal) {
          Future<void> pickDateTime() async {
            final now = DateTime.now();
            final d = await showDatePicker(
              context: context,
              initialDate: when ?? now,
              firstDate: DateTime(now.year - 1),
              lastDate: DateTime(now.year + 5),
            );
            if (d == null || !context.mounted) return;
            final t = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(when ?? now),
            );
            if (t == null) return;
            setLocal(() {
              when = DateTime(d.year, d.month, d.day, t.hour, t.minute);
              dateError = null;
            });
          }

          Future<void> save() async {
            final ok = formKey.currentState!.validate();
            if (when == null) {
              setLocal(() => dateError = 'Please choose a date and time');
              return;
            }
            if (!ok) return;
            setLocal(() => saving = true);
            try {
              final payload = {
                'title': title.text.trim(),
                'description': desc.text.trim(),
                'location': loc.text.trim(),
                'date': Timestamp.fromDate(when!),
              };
              if (doc == null) {
                await _db.collection('events').add({
                  ...payload,
                  'createdAt': FieldValue.serverTimestamp(),
                });
              } else {
                await doc.reference.update({
                  ...payload,
                  'updatedAt': FieldValue.serverTimestamp(),
                });
              }
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              _snack(doc == null ? 'Event added' : 'Event updated');
            } catch (e) {
              setLocal(() => saving = false);
              _snack('Could not save event: $e', error: true);
            }
          }

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(doc == null ? 'Add Event' : 'Edit Event',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.navy)),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: title,
                        decoration: const InputDecoration(labelText: 'Title *'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Title is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: pickDateTime,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Date & time *',
                            errorText: dateError,
                            suffixIcon: const Icon(Icons.event_outlined),
                          ),
                          child: Text(
                            when == null ? 'Tap to choose' : _fmtDate(when!),
                            style: TextStyle(
                                fontSize: 15,
                                color: when == null
                                    ? AppTheme.textSecondary
                                    : AppTheme.textPrimary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: loc,
                        decoration:
                            const InputDecoration(labelText: 'Location'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: desc,
                        maxLines: 3,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(dialogContext),
                child: const Text('Cancel',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ),
              ElevatedButton(
                onPressed: saving ? null : save,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(96, 44)),
                child: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.white))
                    : const Text('Save'),
              ),
            ],
          );
        },
      ),
    );

    title.dispose();
    desc.dispose();
    loc.dispose();
  }

  // ───────────────────────── ANNOUNCEMENT FORM ─────────────────────────

  Future<void> _openAnnouncementForm({DocumentSnapshot? doc}) async {
    final data = (doc?.data() as Map<String, dynamic>?) ?? {};
    final title = TextEditingController(text: data['title'] as String? ?? '');
    final desc =
        TextEditingController(text: data['description'] as String? ?? '');
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocal) {
          Future<void> save() async {
            if (!formKey.currentState!.validate()) return;
            setLocal(() => saving = true);
            try {
              final payload = {
                'title': title.text.trim(),
                'description': desc.text.trim(),
              };
              if (doc == null) {
                await _db.collection('announcements').add({
                  ...payload,
                  'createdAt': FieldValue.serverTimestamp(),
                });
              } else {
                await doc.reference.update({
                  ...payload,
                  'updatedAt': FieldValue.serverTimestamp(),
                });
              }
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              _snack(doc == null
                  ? 'Announcement posted'
                  : 'Announcement updated');
            } catch (e) {
              setLocal(() => saving = false);
              _snack('Could not save announcement: $e', error: true);
            }
          }

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(doc == null ? 'New Announcement' : 'Edit Announcement',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.navy)),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: title,
                        decoration: const InputDecoration(labelText: 'Title *'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Title is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: desc,
                        maxLines: 5,
                        decoration: const InputDecoration(
                            labelText: 'Message *', alignLabelWithHint: true),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Message is required'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(dialogContext),
                child: const Text('Cancel',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ),
              ElevatedButton(
                onPressed: saving ? null : save,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(96, 44)),
                child: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.white))
                    : Text(doc == null ? 'Post' : 'Save'),
              ),
            ],
          );
        },
      ),
    );

    title.dispose();
    desc.dispose();
  }

  // ───────────────────────── DELETE ─────────────────────────

  Future<void> _confirmDelete(DocumentSnapshot doc, String what) async {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final name = data['title'] as String? ?? what;
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete $what?',
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        content: Text('"$name" will be removed for all members. This cannot be undone.',
            style: const TextStyle(
                fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                minimumSize: const Size(88, 40)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    try {
      await doc.reference.delete();
      _snack('$what deleted');
    } catch (e) {
      _snack('Could not delete: $e', error: true);
    }
  }

  // ───────────────────────── UI ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final onEvents = _tab.index == 0;
    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.navy,
        foregroundColor: AppTheme.white,
        onPressed: () =>
            onEvents ? _openEventForm() : _openAnnouncementForm(),
        icon: const Icon(Icons.add),
        label: Text(onEvents ? 'Add Event' : 'New Announcement'),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Container(
            color: AppTheme.navy,
            child: TabBar(
              controller: _tab,
              indicatorColor: AppTheme.white,
              indicatorWeight: 3,
              labelColor: AppTheme.white,
              unselectedLabelColor: Colors.white54,
              labelStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              tabs: const [Tab(text: 'Events'), Tab(text: 'Announcements')],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [_buildEventsList(), _buildAnnouncementsList()],
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
        bottom: 12,
        left: 16,
        right: 16,
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
          const Text('Events & Announcements',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.white)),
        ],
      ),
    );
  }

  Widget _empty(IconData icon, String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppTheme.border),
            const SizedBox(height: 12),
            Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('events').orderBy('date').snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return _empty(Icons.error_outline, 'Could not load events: ${snap.error}');
        }
        if (!snap.hasData) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.navy));
        }
        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return _empty(Icons.event_outlined,
              'No events yet.\nTap "Add Event" to publish one for members.');
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final doc = docs[i];
            final d = doc.data() as Map<String, dynamic>;
            final dt = (d['date'] as Timestamp?)?.toDate();
            final upcoming = dt != null && dt.isAfter(DateTime.now());
            final loc = (d['location'] as String? ?? '').trim();
            final desc = (d['description'] as String? ?? '').trim();
            return _card(
              leading: Container(
                width: 46,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: upcoming ? AppTheme.navy : AppTheme.navyLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(dt == null ? '-' : '${dt.day}',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            height: 1,
                            color:
                                upcoming ? AppTheme.white : AppTheme.navy)),
                    const SizedBox(height: 2),
                    Text(dt == null ? '' : _months[dt.month - 1].toUpperCase(),
                        style: TextStyle(
                            fontSize: 10,
                            color: upcoming
                                ? Colors.white70
                                : AppTheme.textSecondary)),
                  ],
                ),
              ),
              title: d['title'] as String? ?? '',
              lines: [
                if (dt != null) _fmtDate(dt),
                if (loc.isNotEmpty) loc,
                if (desc.isNotEmpty) desc,
              ],
              badge: upcoming ? 'Upcoming' : 'Past',
              onEdit: () => _openEventForm(doc: doc),
              onDelete: () => _confirmDelete(doc, 'event'),
            );
          },
        );
      },
    );
  }

  Widget _buildAnnouncementsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return _empty(
              Icons.error_outline, 'Could not load announcements: ${snap.error}');
        }
        if (!snap.hasData) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.navy));
        }
        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return _empty(Icons.campaign_outlined,
              'No announcements yet.\nTap "New Announcement" to post one for members.');
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final doc = docs[i];
            final d = doc.data() as Map<String, dynamic>;
            final posted = (d['createdAt'] as Timestamp?)?.toDate();
            return _card(
              leading: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                    color: AppTheme.navyLight,
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.campaign_outlined,
                    color: AppTheme.navy, size: 22),
              ),
              title: d['title'] as String? ?? '',
              lines: [
                if (posted != null)
                  'Posted ${posted.day} ${_months[posted.month - 1]} ${posted.year}',
                (d['description'] as String? ?? '').trim(),
              ].where((s) => s.isNotEmpty).toList(),
              onEdit: () => _openAnnouncementForm(doc: doc),
              onDelete: () => _confirmDelete(doc, 'announcement'),
            );
          },
        );
      },
    );
  }

  Widget _card({
    required Widget leading,
    required String title,
    required List<String> lines,
    String? badge,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary)),
                    ),
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: badge == 'Upcoming'
                              ? AppTheme.successLight
                              : AppTheme.navyLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(badge,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: badge == 'Upcoming'
                                    ? AppTheme.success
                                    : AppTheme.textSecondary)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                for (final l in lines)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(l,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12.5,
                            color: AppTheme.textSecondary,
                            height: 1.4)),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(
                          foregroundColor: AppTheme.navy,
                          padding: const EdgeInsets.symmetric(horizontal: 8)),
                    ),
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(
                          foregroundColor: AppTheme.error,
                          padding: const EdgeInsets.symmetric(horizontal: 8)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
