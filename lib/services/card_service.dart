/// Helpers for the yearly Monthly Collection card (financial year Apr–Mar).
class CardService {
  /// Financial year start (e.g. 2026 for Apr 2026 – Mar 2027) of a date.
  static int fyStartOf(DateTime d) => d.month >= 4 ? d.year : d.year - 1;

  static int currentFyStart() => fyStartOf(DateTime.now());

  /// "2026-27"
  static String fyName(int start) =>
      '$start-${((start + 1) % 100).toString().padLeft(2, '0')}';

  /// "FY 2026-27"
  static String fyLabel(int start) => 'FY ${fyName(start)}';

  /// Parses "FY 2026-27" back to 2026 (null if not an FY label).
  static int? parseFyLabel(String label) {
    if (!label.startsWith('FY ')) return null;
    return int.tryParse(label.substring(3, 7));
  }

  /// One card per member per financial year; same id = replace.
  static String docId(String memberId, int fyStart) => '${memberId}_$fyStart';
}
