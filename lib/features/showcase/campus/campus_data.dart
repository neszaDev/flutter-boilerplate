import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// Placeholder payloads for the campus screens, shaped like the Vue app's API responses
// (`{ _id, title: [{ key, value }] }`): the web app's `CampusPlaceholders.ts` and
// `components/campus/data.ts`. The Spring API does not serve these yet (see the web app's
// docs/plans/0003-vue-ui-port.md); `campus_providers.dart` hands them out until it does.

/// A title in one language, as the Vue API sends it (`{ key, value }`).
@immutable
class LocalizedTitle {
  const LocalizedTitle(this.key, this.value);

  /// Language code: `en`, `th`…
  final String key;
  final String value;
}

/// An organisation, agency or department.
@immutable
class OrgUnit {
  const OrgUnit({required this.id, required this.title});

  /// `_id` in the Vue API.
  final String id;

  /// One title per language.
  final List<LocalizedTitle> title;
}

/// The three lists of the organisation filter.
@immutable
class OrgUnits {
  const OrgUnits({required this.organizations, required this.agencies, required this.departments});

  final List<OrgUnit> organizations;
  final List<OrgUnit> agencies;
  final List<OrgUnit> departments;
}

/// The social accounts a campus profile can link.
enum SocialNetwork { facebook, instagram, google }

/// The signed-in person's campus profile (Vue `system/profile`).
@immutable
class CampusProfile {
  const CampusProfile({
    required this.name,
    required this.agency,
    required this.branch,
    required this.position,
    required this.mobile,
    required this.email,
    required this.gender,
    required this.birthDate,
    required this.address,
    required this.links,
    this.avatar,
  });

  final String name;

  /// Photo URL. The app bundles no sample photo, so the placeholder has none and the initials
  /// show instead.
  final String? avatar;
  final String agency;
  final String branch;
  final String position;
  final String mobile;
  final String email;
  final String gender;

  /// As the Vue API sends it (`dd/MM/yyyy`).
  final String birthDate;
  final String address;

  /// The account name per network, or null when it isn't linked.
  final Map<SocialNetwork, String?> links;
}

OrgUnit _unit(String id, String en, String th) =>
    OrgUnit(id: id, title: [LocalizedTitle('en', en), LocalizedTitle('th', th)]);

final placeholderOrgUnits = OrgUnits(
  organizations: [_unit('org-1', 'Mae Fah Luang University', 'มหาวิทยาลัยแม่ฟ้าหลวง')],
  agencies: [
    _unit('agency-1', 'Service centre', 'ศูนย์บริการ'),
    _unit('agency-2', 'Personnel division', 'ส่วนการเจ้าหน้าที่'),
  ],
  departments: [
    _unit('dept-1', 'Information technology centre', 'ศูนย์เทคโนโลยีสารสนเทศ'),
    _unit('dept-2', 'School of management', 'สำนักวิชาการจัดการ'),
  ],
);

const placeholderProfile = CampusProfile(
  name: 'Alex Martin',
  agency: 'ศูนย์บริการ',
  branch: 'ศูนย์เทคโนโลยีสารสนเทศ',
  position: 'นักศึกษา',
  mobile: '+66 80 000 0000',
  email: 'alex.martin@example.com',
  gender: 'Not stated',
  birthDate: '01/01/2000',
  address: '1 Example Road',
  links: {
    SocialNetwork.facebook: 'xxxx',
    SocialNetwork.instagram: 'xxxx',
    SocialNetwork.google: 'xxxx',
  },
);

/// The brand colour of each network's logo on the profile card (data, not theme).
const socialBrandColors = {
  SocialNetwork.facebook: Color(0xFF1877F2),
  SocialNetwork.instagram: Color(0xFFE4405F),
  SocialNetwork.google: Color(0xFF4285F4),
};

/// Which `CampusLauncher.category_*` label a launcher category shows.
enum LauncherCategoryName { events, services, application, businessIntelligence }

/// An app tile of the launcher; every sample app is labelled `CampusLauncher.app_application`.
@immutable
class LauncherApp {
  const LauncherApp({required this.id, required this.badge, required this.icon});

  final String id;

  /// Unread notifications.
  final int badge;
  final IconData icon;
}

/// A launcher category with its apps.
@immutable
class LauncherCategory {
  const LauncherCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.apps,
  });

  final String id;
  final LauncherCategoryName name;
  final IconData icon;
  final List<LauncherApp> apps;
}

/// The Vue dashboard's sample launcher (src/projects/views/dashboards/index.vue).
const launcherCategories = [
  LauncherCategory(
    id: '1',
    name: LauncherCategoryName.events,
    icon: LucideIcons.ticket,
    apps: [LauncherApp(id: '1-1', badge: 0, icon: LucideIcons.gauge)],
  ),
  LauncherCategory(
    id: '2',
    name: LauncherCategoryName.services,
    icon: LucideIcons.paintbrush,
    apps: [LauncherApp(id: '2-1', badge: 100, icon: LucideIcons.gauge)],
  ),
  LauncherCategory(
    id: '3',
    name: LauncherCategoryName.application,
    icon: LucideIcons.smartphone,
    apps: [LauncherApp(id: '3-1', badge: 100, icon: LucideIcons.gauge)],
  ),
  LauncherCategory(
    id: '4',
    name: LauncherCategoryName.businessIntelligence,
    icon: LucideIcons.briefcase,
    apps: [LauncherApp(id: '4-1', badge: 100, icon: LucideIcons.gauge)],
  ),
];

/// Contacts and documents of the sign-in help dialog (Vue `SignIn.vue`).
abstract final class SignInHelp {
  static const phone = '0-5391-6494, 6053';

  /// [phone] for the dialer: the number, a pause, then the extension.
  static final phoneUri = Uri(scheme: 'tel', path: '053916494,6053');
  static const email = 'personnel@mfu.ac.th';
  static final competencyThai = Uri.parse(
    'https://drive.google.com/file/d/1obIc3c5kEJ6nP1rBH5uA9nvw62fjzTid/view?usp=sharing',
  );
  static final competencyEnglish = Uri.parse(
    'https://drive.google.com/file/d/1Ds3wv_QlPoA_M10i2snrzrh5Ri_Qi9wQ/view?usp=sharing',
  );
  static final manualThai = Uri.parse(
    'https://drive.google.com/file/d/1YJxsIbrhgp9tsfz-neHuEDC39mgUpWqg/view?usp=sharing',
  );
  static final manualEnglish = Uri.parse(
    'https://drive.google.com/file/d/1dGYb9s9X1WVuPwEWW3xaScCUEsODxwkA/view?usp=sharing',
  );
  static final issueForm = Uri.parse(
    'https://docs.google.com/forms/d/e/1FAIpQLSec2LSaDE1flmQULhl7bsCbTOZl4nd1VGfSv3LDxP7bnuZ9iQ/viewform',
  );
}

/// What the QR code card starts with (Vue `QRCodes.vue` defaults, with a real address).
const qrDefaults = (text: 'https://www.mfu.ac.th', label: 'MFU');
