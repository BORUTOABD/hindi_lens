import 'package:flutter_test/flutter_test.dart';
import 'package:hindi_lens/main.dart';

void main() {
  testWidgets('HindiLens initial screen displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const HindiLensApp());

    expect(find.text('HindiLens'), findsOneWidget);
    expect(find.text('Translate Text from Images'), findsOneWidget);
    expect(find.text('Take a Photo'), findsOneWidget);
    expect(find.text('Choose from Gallery'), findsOneWidget);
  });
}