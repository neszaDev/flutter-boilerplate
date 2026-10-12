import 'package:flutter_boilerplate/features/showcase/campus/campus_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Placeholders, like the web app's `listOrgUnits` and `getCampusProfile` in Queries.ts. They
// become repository calls once the Spring API serves the Vue app's
// `/organization/explorers` (and the agency and department explorers) and `/system/profile`.

/// Organisations, agencies and departments for the campus filters.
final orgUnitsProvider = FutureProvider.autoDispose<OrgUnits>((ref) async {
  await Future<void>.delayed(Duration.zero);
  return placeholderOrgUnits;
});

/// The signed-in person's campus profile.
final campusProfileProvider = FutureProvider.autoDispose<CampusProfile>((ref) async {
  await Future<void>.delayed(Duration.zero);
  return placeholderProfile;
});
