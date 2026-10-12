import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/campus/widgets/message_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

import 'campus_test_app.dart';

void main() {
  group('MessageDialog', () {
    testWidgets('shows the message with its code and reports the pressed button', (tester) async {
      String? pressed;
      await pumpCampusWidget(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              pressed = await showMessageDialog(
                context,
                content: const DialogMessageContent(
                  title: 'Error',
                  message: 'The code has expired.',
                  number: '1',
                  code: '40100',
                ),
                buttons: const [
                  DialogMessageButton(code: 'cancel', label: 'Cancel'),
                  DialogMessageButton(
                    code: 'retry',
                    label: 'Try again',
                    variant: DialogButtonVariant.primary,
                  ),
                ],
              );
            },
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Error'), findsOneWidget);
      expect(find.text('The code has expired.'), findsOneWidget);
      expect(find.text('# 1-40100'), findsOneWidget);
      expect(find.bySemanticsLabel('Reference 1-40100'), findsOneWidget);

      // A tap outside doesn't close it.
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(find.text('The code has expired.'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(pressed, 'retry');
      expect(find.text('The code has expired.'), findsNothing);
    });
  });
}
