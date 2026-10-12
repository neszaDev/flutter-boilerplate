import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/plugins/calendar_math.dart';
import 'package:flutter_boilerplate/features/showcase/plugins/event_calendar.dart';

/// `/dashboard/plugins/calendar`: a month calendar with events across days, by year, month or
/// week.
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.calendarPageTitle,
      description: Text(l10n.calendarPageDescription),
      children: [
        DemoCard(
          title: l10n.calendarPageCardTitle,
          description: l10n.calendarPageCardDescription,
          // Seven day columns need the width more than the card needs its margin.
          padding: const EdgeInsets.all(Space.md),
          child: EventCalendar(today: startOfDay(DateTime.now())),
        ),
      ],
    );
  }
}
