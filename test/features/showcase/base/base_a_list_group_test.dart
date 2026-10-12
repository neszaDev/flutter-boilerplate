import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/base/base_a_list_group.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base_a_harness.dart';

void main() {
  group('ButtonListGroup', () {
    const list = ButtonListGroup(
      label: 'Buttons',
      items: [
        (id: 'one', label: 'Button item', disabled: false),
        (id: 'two', label: 'I am a button', disabled: false),
        (id: 'off', label: 'Disabled button', disabled: true),
      ],
    );

    testWidgets('selects the pressed button and only that one', (tester) async {
      await pumpBase(tester, list);

      expect(
        tester.getSemantics(find.text('Button item')),
        isSemantics(isButton: true, isSelected: false),
      );

      await tester.tap(find.text('I am a button'));
      await tester.pump();
      await tester.tap(find.text('Button item'));
      await tester.pump();

      expect(tester.getSemantics(find.text('Button item')), isSemantics(isSelected: true));
      expect(tester.getSemantics(find.text('I am a button')), isSemantics(isSelected: false));
    });

    testWidgets('keeps a disabled button out of reach', (tester) async {
      await pumpBase(tester, list);

      await tester.tap(find.text('Disabled button'));
      await tester.pump();

      expect(
        tester.getSemantics(find.text('Disabled button')),
        isSemantics(isEnabled: false, isSelected: false),
      );
    });
  });

  group('ListGroupItem', () {
    testWidgets('follows a link row and marks the current one', (tester) async {
      var taps = 0;
      await pumpBase(
        tester,
        ListGroup(
          label: 'Links',
          children: [
            ListGroupItem(onTap: () => taps++, child: const Text('Go')),
            ListGroupItem(active: true, onTap: () {}, child: const Text('Here')),
            ListGroupItem(disabled: true, onTap: () => taps++, child: const Text('Off')),
          ],
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.tap(find.text('Off'));

      expect(taps, 1);
      expect(tester.getSemantics(find.text('Go')), isSemantics(isLink: true));
      expect(tester.getSemantics(find.text('Here')), isSemantics(isLink: true, isSelected: true));
      expect(tester.getSemantics(find.text('Off')), isSemantics(isEnabled: false));
    });
  });
}
