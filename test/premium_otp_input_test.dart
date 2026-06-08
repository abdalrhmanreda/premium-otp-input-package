import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:premium_otp_input/premium_otp_input.dart';

void main() {
  testWidgets('PremiumOtpInput can be created with default parameters', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PremiumOtpInput(length: 6),
        ),
      ),
    );

    expect(find.byType(PremiumOtpInput), findsOneWidget);
  });

  testWidgets('PremiumOtpInput can be customized with styling parameters', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PremiumOtpInput(
            length: 4,
            boxHeight: 72.0,
            spacing: 16.0,
            borderRadius: 12.0,
            defaultBorderColor: Colors.blue,
            activeBorderColor: Colors.amber,
            errorColor: Colors.redAccent,
            successColor: Colors.greenAccent,
            boxBackgroundColor: Colors.black38,
            loadingBorderColor: Colors.cyan,
            loadingBorderStrokeWidth: 3.0,
            emptyDotColor: Colors.grey,
            emptyDotSize: 8.0,
            textStyle: const TextStyle(fontSize: 20, color: Colors.amber),
            successCheckmarkColor: Colors.black,
            successCheckmarkSize: 40.0,
          ),
        ),
      ),
    );

    expect(find.byType(PremiumOtpInput), findsOneWidget);
  });

  testWidgets('PremiumOtpInput supports custom animation parameters', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PremiumOtpInput(
            length: 4,
            entryAnimationStyle: OtpEntryAnimationStyle.fade,
            successAnimationStyle: OtpSuccessAnimationStyle.none,
            animateActiveBorder: false,
          ),
        ),
      ),
    );

    expect(find.byType(PremiumOtpInput), findsOneWidget);
  });

  testWidgets('PremiumOtpInput obscureText obscures entered digits', (WidgetTester tester) async {
    final controller = TextEditingController(text: '12');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PremiumOtpInput(
            length: 4,
            controller: controller,
            obscureText: true,
            obscuringCharacter: '*',
          ),
        ),
      ),
    );

    expect(find.text('*'), findsNWidgets(2));
    expect(find.text('1'), findsNothing);
    expect(find.text('2'), findsNothing);
  });
}
