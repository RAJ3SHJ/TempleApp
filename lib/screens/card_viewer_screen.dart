import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/download_stub.dart'
    if (dart.library.js_interop) '../services/download_web.dart';

/// Full-screen, zoomable view of a Monthly Collection card with a Download button.
class CardViewerScreen extends StatelessWidget {
  final String title;
  final String imageBase64;
  final String fileName;
  const CardViewerScreen({
    super.key,
    required this.title,
    required this.imageBase64,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    final Uint8List bytes = base64Decode(imageBase64);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppTheme.navy,
        foregroundColor: AppTheme.white,
        title: Text(title, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton.icon(
            onPressed: () {
              final ok = downloadBytes(bytes, fileName);
              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Download is available in the web version.')));
              }
            },
            icon: const Icon(Icons.download_rounded, color: AppTheme.white),
            label: const Text('Download', style: TextStyle(color: AppTheme.white)),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 6,
          child: Image.memory(bytes, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
