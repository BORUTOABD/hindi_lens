import 'package:flutter_test/flutter_test.dart';
import 'package:hindi_lens/main.dart';

void main() {
  testWidgets('HindiLens initial screen displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const HindiLensApp());

    // Verify app title and introductory texts exist
    expect(find.text('HindiLens'), findsOneWidget);
    expect(find.text('Translate Hindi from Images'), findsOneWidget);

    // Verify Camera and Gallery input triggers exist
    expect(find.text('Take a Photo'), findsOneWidget);
    expect(find.text('Choose from Gallery'), findsOneWidget);

    // Verify reverse translation mode is strictly absent
    expect(find.text('English → Hindi'), findsNothing);
  });
}