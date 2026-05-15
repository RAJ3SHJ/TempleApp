import 'package:flutter_test/flutter_test.dart';
import 'package:temple_app/main.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const TempleApp());
  });
}
