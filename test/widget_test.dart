import 'package:flutter_test/flutter_test.dart';
import 'package:wallpaper/main.dart';

void main() {
  testWidgets('shows wallpaper home title', (WidgetTester tester) async {
    await tester.pumpWidget(const WallpaperApp());
    await tester.pump();
    expect(find.text('خلفيات'), findsWidgets);
    await tester.pump(const Duration(milliseconds: 400));
  });
}
