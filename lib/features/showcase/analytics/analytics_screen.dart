import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/widgets/page_layout.dart';
import 'package:flutter_boilerplate/features/showcase/analytics/traffic_card.dart';
import 'package:flutter_boilerplate/features/showcase/analytics/traffic_sales.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/widgets_brand.dart';
import 'package:flutter_boilerplate/features/showcase/widgets/widgets_dropdown.dart';

/// `/dashboard/analytics`: the dashboard of the template with sample figures: the dropdown
/// widgets, the traffic chart, the brand widgets, and traffic and sales with the users table.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPage(
      title: l10n.analyticsPageTitle,
      description: Text(l10n.analyticsPageDescription),
      children: const [
        WidgetsDropdown(),
        TrafficCard(),
        WidgetsBrand(charts: true),
        TrafficSales(),
      ],
    );
  }
}
