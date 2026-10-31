import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../services/card_service.dart';
import '../card_viewer_screen.dart';

/// Admin / Super Admin: view, upload or replace a member's yearly card.
class MemberCardScreen extends StatefulWidget {
  final String memberId;
  final String memberName;
  const MemberCardScreen({super.key, required this.memberId, required this.memberName});

  @override
  State<MemberCardScreen> createState() => _MemberCardScreenState();
}

class _MemberCardScreenState extends State<MemberCardScreen> {
  bool _busy = false;

  Future<void> _upload(int fy, bool exists) async {
    setState(() => _busy = true);
    try {
      // Resized and compressed by the picker to keep the file small.
      final XFile? picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 2000,
        imageQuality: 70,
      );
      if (picked == null) return;
      final Uint8List bytes = await picked.readAsBytes();
      if (bytes.length > 800 * 1024) {
        _snack('Photo is too large even after shrinking. Please retake it closer or in better light.');
        return;
      }
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Save card for ${widget.memberName}?'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${widget.memberId} · ${CardService.fyLabel(fy)}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                if (exists)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text('This will replace the existing card for this year.',
                        style: TextStyle(color: AppTheme.error)),
                  ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  child: Image.memory(bytes, fit: BoxFit.contain),
                ),
                const SizedBox(height: 6),
                Text('${(bytes.length / 1024).round()} KB',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
          ],
        ),
      );
      if (confirmed != true) return;
      await FirebaseFirestore.instance
          .collection('membercards')
          .doc(CardService.docId(widget.memberId, fy))
          .set({
        'memberId': widget.memberId,
        'memberName': widget.memberName,
        'fyStart': fy,
        'imageBase64': base64Encode(bytes),
        'sizeBytes': bytes.length,
        'uploadedAt': FieldValue.serverTimestamp(),
        'uploadedBy': FirebaseAuth.instance.currentUser?.uid,
      });
      _snack('Card saved for ${CardService.fyLabel(fy)}.');
    } catch (e) {
      _snack('Could not save the card: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    final cur = CardService.currentFyStart();
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.navy,
        foregroundColor: AppTheme.white,
        title: Text('Card · ${widget.memberName}', style: const TextStyle(fontSize: 16)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('membercards')
            .where('memberId', isEqualTo: widget.memberId)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Could not load cards: ${snap.error}', textAlign: TextAlign.center),
            ));
          }
          final cards = <int, Map<String, dynamic>>{};
          for (final d in snap.data?.docs ?? <QueryDocumentSnapshot>[]) {
            final m = d.data() as Map<String, dynamic>;
            final fy = (m['fyStart'] as num?)?.toInt();
            if (fy != null) cards[fy] = m;
          }
          final years = <int>{cur + 1, cur, cur - 1, cur - 2, ...cards.keys}.toList()
            ..sort((a, b) => b.compareTo(a));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('${widget.memberName} · ${widget.memberId}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.navy)),
              const SizedBox(height: 4),
              const Text('One card per financial year (April to March). Uploading again for the same year replaces the card.',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 16),
              for (final fy in years) _row(fy, cards[fy]),
              if (_busy) const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(int fy, Map<String, dynamic>? card) {
    final exists = card != null;
    final ts = card?['uploadedAt'];
    String when = '';
    if (ts is Timestamp) {
      final d = ts.toDate();
      when = 'Uploaded ${d.day}/${d.month}/${d.year}';
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(CardService.fyLabel(fy),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.navy)),
                const SizedBox(height: 2),
                Text(exists ? when : 'No card uploaded',
                    style: TextStyle(fontSize: 13, color: exists ? AppTheme.success : AppTheme.textSecondary)),
              ],
            ),
          ),
          if (exists)
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => CardViewerScreen(
                  title: '${widget.memberName} · ${CardService.fyLabel(fy)}',
                  imageBase64: card['imageBase64'] as String,
                  fileName: '${widget.memberId}_${CardService.fyName(fy)}.jpg',
                ),
              )),
              child: const Text('View'),
            ),
          TextButton(
            onPressed: _busy ? null : () => _upload(fy, exists),
            child: Text(exists ? 'Replace' : 'Upload'),
          ),
        ],
      ),
    );
  }
}
