import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/showcase/forms/combobox.dart';
import 'package:flutter_boilerplate/features/showcase/forms/forms_data.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pump.dart';

/// A states combobox that prints its value, like the web test's `StatesField`.
class _StatesField extends StatefulWidget {
  const _StatesField({this.multiple = false});

  final bool multiple;

  @override
  State<_StatesField> createState() => _StatesFieldState();
}

class _StatesFieldState extends State<_StatesField> {
  List<String> _value = const [];

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Combobox(
        key: const Key('states'),
        label: 'States',
        options: usStates,
        value: _value,
        onChanged: (value) => setState(() => _value = value),
        multiple: widget.multiple,
        clearable: true,
        placeholder: 'Select option',
      ),
      Text('value=${_value.join(',')}'),
    ],
  );
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('states')));
  await tester.pumpAndSettle();
}

Future<void> _search(WidgetTester tester, String query) async {
  await tester.enterText(
    find.descendant(of: find.byType(BottomSheet), matching: find.byType(TextField)),
    query,
  );
  await tester.pumpAndSettle();
}

void main() {
  group('toggleSelection', () {
    test('adds and removes values of a multiple selection', () {
      expect(toggleSelection(['AL'], 'CA', multiple: true), ['AL', 'CA']);
      expect(toggleSelection(['AL', 'CA'], 'AL', multiple: true), ['CA']);
    });

    test('keeps one value in a single selection', () {
      expect(toggleSelection(['AL'], 'CA', multiple: false), ['CA']);
      expect(toggleSelection(['CA'], 'CA', multiple: false), ['CA']);
    });
  });

  group('filterOptions', () {
    test('matches labels anywhere and values from the start, ignoring case', () {
      expect(filterOptions(usStates, 'calif').map((option) => option.value), ['CA']);
      expect(filterOptions(usStates, 'tx').map((option) => option.value), ['TX']);
      expect(filterOptions(usStates, ''), usStates);
      expect(filterOptions(usStates, 'zzz'), isEmpty);
    });
  });

  group('Combobox', () {
    group('multiple', () {
      testWidgets('adds searched options as chips and removes them again', (tester) async {
        await pumpDemo(tester, const _StatesField(multiple: true));

        await _open(tester);
        await _search(tester, 'calif');
        await tester.tap(find.text('California'));
        await tester.pumpAndSettle();
        await _search(tester, 'texas');
        await tester.tap(find.text('Texas'));
        await tester.pumpAndSettle();

        expect(find.text('value=CA,TX'), findsOneWidget);

        await tester.tap(find.text(en.comboboxDone));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip(en.comboboxRemove('California')));
        await tester.pumpAndSettle();

        expect(find.text('value=TX'), findsOneWidget);
        expect(find.byTooltip(en.comboboxRemove('California')), findsNothing);
      });

      testWidgets('does not pick a disabled option', (tester) async {
        await pumpDemo(tester, const _StatesField(multiple: true));

        await _open(tester);

        final samoa = tester.widget<CheckboxListTile>(
          find.widgetWithText(CheckboxListTile, 'American Samoa'),
        );
        expect(samoa.onChanged, isNull);
      });

      testWidgets('says when no option matches', (tester) async {
        await pumpDemo(tester, const _StatesField(multiple: true));

        await _open(tester);
        await _search(tester, 'zzz');

        expect(find.text(en.comboboxEmpty), findsOneWidget);
      });
    });

    group('single', () {
      testWidgets('shows the chosen option, closes, and clears', (tester) async {
        await pumpDemo(tester, const _StatesField());

        await _open(tester);
        await tester.tap(find.text('Alaska'));
        await tester.pumpAndSettle();

        expect(find.byType(BottomSheet), findsNothing);
        expect(find.text('Alaska'), findsOneWidget);
        expect(find.text('value=AK'), findsOneWidget);

        await tester.tap(find.byTooltip(en.comboboxClear));
        await tester.pumpAndSettle();

        expect(find.text('value='), findsOneWidget);
        expect(find.text('Select option'), findsOneWidget);
      });
    });
  });
}
