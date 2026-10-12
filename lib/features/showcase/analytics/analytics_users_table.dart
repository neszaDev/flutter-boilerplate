import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/showcase/analytics/analytics_data.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/brand_icon.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/tone_progress.dart';
import 'package:intl/intl.dart';

/// "5 minutes ago": [relativeTime] in words.
String relativeTimeText(AppLocalizations l10n, int secondsAgo) {
  final (:unit, :value) = relativeTime(secondsAgo);
  return switch (unit) {
    RelativeUnit.second => l10n.analyticsUsersAgoSecond(value),
    RelativeUnit.minute => l10n.analyticsUsersAgoMinute(value),
    RelativeUnit.hour => l10n.analyticsUsersAgoHour(value),
    RelativeUnit.day => l10n.analyticsUsersAgoDay(value),
    RelativeUnit.week => l10n.analyticsUsersAgoWeek(value),
    RelativeUnit.month => l10n.analyticsUsersAgoMonth(value),
    RelativeUnit.year => l10n.analyticsUsersAgoYear(value),
  };
}

/// The country name of an ISO code of the sample users (Dart has no region display names).
String countryName(AppLocalizations l10n, String code) => switch (code) {
  'US' => l10n.analyticsUsersCountryUs,
  'BR' => l10n.analyticsUsersCountryBr,
  'IN' => l10n.analyticsUsersCountryIn,
  'FR' => l10n.analyticsUsersCountryFr,
  'ES' => l10n.analyticsUsersCountryEs,
  'PL' => l10n.analyticsUsersCountryPl,
  _ => code,
};

const _widths = <double>[60, 200, 128, 208, 96, 140];

/// The dashboard's users table: avatar with presence, name and registration, country, usage
/// bar for the period, payment method and last login. Wider than a phone, it scrolls sideways.
class AnalyticsUsersTable extends StatelessWidget {
  const AnalyticsUsersTable({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final head = context.type.formLabel;
    Widget header(String text, {bool center = false}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.md),
      child: Text(
        text.toUpperCase(),
        style: head,
        textAlign: center ? TextAlign.center : TextAlign.start,
      ),
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.ply,
        border: Border.all(color: colors.ink200),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          columnWidths: {
            for (final (index, width) in _widths.indexed) index: FixedColumnWidth(width),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder(horizontalInside: BorderSide(color: colors.ink200)),
          children: [
            TableRow(
              decoration: BoxDecoration(color: colors.paper),
              children: [
                Semantics(
                  label: l10n.analyticsUsersColumnAvatar,
                  child: const SizedBox(height: 40),
                ),
                header(l10n.analyticsUsersColumnUser),
                header(l10n.analyticsUsersColumnCountry),
                header(l10n.analyticsUsersColumnUsage),
                header(l10n.analyticsUsersColumnPayment, center: true),
                header(l10n.analyticsUsersColumnActivity),
              ],
            ),
            for (final user in analyticsUsers) _row(context, user),
          ],
        ),
      ),
    );
  }

  TableRow _row(BuildContext context, AnalyticsUser user) {
    final l10n = context.l10n;
    final colors = context.colors;
    final medium = DateFormat.yMMMd(context.localeName);
    final percent = NumberFormat.percentPattern(context.localeName);
    final small = context.text.bodySmall;
    final strong = context.type.table.copyWith(fontWeight: FontWeight.w600, color: colors.ink950);
    Widget cell(Widget child) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.md),
      child: child,
    );

    return TableRow(
      children: [
        cell(_Avatar(user: user)),
        cell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name, style: strong),
              Text(
                l10n.analyticsUsersRegistered(
                  user.isNew ? 'new' : 'recurring',
                  medium.format(user.registered),
                ),
                style: small,
              ),
            ],
          ),
        ),
        cell(Text(countryName(l10n, user.country), style: context.type.table)),
        cell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(percent.format(user.usage / 100), style: strong),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: Text(
                      l10n.analyticsUsersDateRange(
                        medium.format(user.usageFrom),
                        medium.format(user.usageTo),
                      ),
                      style: small?.copyWith(fontSize: 12),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ToneProgress(
                value: user.usage,
                tone: usageTone(user.usage),
                label: l10n.analyticsUsersUsageLabel(user.name),
              ),
            ],
          ),
        ),
        cell(
          Center(
            child: BrandIcon(user.payment, label: user.paymentName, size: 24, color: colors.ink700),
          ),
        ),
        cell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.analyticsUsersLastLogin, style: small?.copyWith(fontSize: 12)),
              Text(relativeTimeText(l10n, user.lastSeenSecondsAgo), style: strong),
            ],
          ),
        ),
      ],
    );
  }
}

/// Initials in a circle (the sample photos are not bundled), with the presence dot.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});

  final AnalyticsUser user;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final initials = user.name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.characters.first)
        .join();
    final (presence, dot) = switch (user.presence) {
      Presence.online => (l10n.analyticsUsersPresenceOnline, colors.pass),
      Presence.busy => (l10n.analyticsUsersPresenceBusy, colors.pencil),
      Presence.away => (l10n.analyticsUsersPresenceAway, colors.ink400),
      Presence.offline => (l10n.analyticsUsersPresenceOffline, colors.ink200),
    };
    return Semantics(
      label: presence,
      child: SizedBox.square(
        dimension: 36,
        child: Stack(
          children: [
            ExcludeSemantics(
              child: CircleAvatar(
                radius: 18,
                backgroundColor: colors.ink100,
                child: Text(
                  initials,
                  style: context.text.labelMedium?.copyWith(color: colors.ink700),
                ),
              ),
            ),
            PositionedDirectional(
              end: 0,
              bottom: 0,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: dot,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.ply, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
