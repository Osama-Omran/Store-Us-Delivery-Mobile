import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storeus_delivery/core/theme/app_theme.dart';
import 'package:storeus_delivery/core/widgets/custom_button.dart';

void main() {
  const longLabel = 'مراجعة المنتجات وتأكيد استلام السيارة للرحلة الحالية';

  Future<void> pumpButton(
    WidgetTester tester, {
    required bool shrink,
    required String label,
    double textScale = 1,
    VoidCallback? onPressed,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: CustomButton(
                    shrink: shrink,
                    text: label,
                    icon: const Icon(Icons.local_shipping_outlined),
                    icon1st: true,
                    vibrate: false,
                    onPressed: onPressed,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  for (final shrink in [false, true]) {
    testWidgets('RTL button wraps enlarged labels with shrink=$shrink', (
      tester,
    ) async {
      var presses = 0;
      await pumpButton(
        tester,
        shrink: shrink,
        label: longLabel,
        textScale: 1.5,
        onPressed: () => presses++,
      );

      expect(tester.takeException(), isNull);
      final buttonSize = tester.getSize(find.byType(CustomButton));
      final labelSize = tester.getSize(find.text(longLabel));
      expect(buttonSize.width, lessThanOrEqualTo(240));
      expect(buttonSize.height, greaterThan(56));
      expect(labelSize.height, greaterThan(24));
      expect(labelSize.width, lessThan(buttonSize.width - 32));

      await tester.tap(find.byType(CustomButton));
      await tester.pump();
      expect(presses, 1);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'Short shrink button retains its natural width and touch height',
    (tester) async {
      await pumpButton(tester, shrink: true, label: 'تأكيد');

      expect(tester.takeException(), isNull);
      final buttonSize = tester.getSize(find.byType(CustomButton));
      expect(buttonSize.width, lessThan(240));
      expect(buttonSize.height, greaterThanOrEqualTo(56));
    },
  );
}
