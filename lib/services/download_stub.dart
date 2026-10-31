import 'dart:typed_data';

/// Fallback for platforms without browser download support.
bool downloadBytes(Uint8List bytes, String filename) => false;
