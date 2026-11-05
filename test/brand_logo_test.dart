import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runrabbit_kiosk/widgets/brand_logo.dart';

void main() {
  testWidgets('BrandLogo renders RUN in bold and RABBIT in regular weight',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BrandLogo(fontSize: 24),
        ),
      ),
    );

    final textFinder = find.descendant(
      of: find.byType(BrandLogo),
      matching: find.byType(Text),
    );
    expect(textFinder, findsOneWidget);

    final textWidget = tester.widget<Text>(textFinder);
    final textSpan = textWidget.textSpan! as TextSpan;

    expect(textSpan.children, isNotNull);
    expect(textSpan.children!.length, 2);

    final runSpan = textSpan.children![0] as TextSpan;
    final rabbitSpan = textSpan.children![1] as TextSpan;

    expect(runSpan.text, 'RUN');
    expect(runSpan.style?.fontWeight, FontWeight.w900);

    expect(rabbitSpan.text, 'RABBIT');
    expect(rabbitSpan.style?.fontWeight, FontWeight.w400);
  });
}
