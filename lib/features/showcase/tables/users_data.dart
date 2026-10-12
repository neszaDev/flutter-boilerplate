import 'dart:math';

/// Account states of the sample users.
enum UserStatus { active, inactive, pending, banned }

enum UserRole { member, staff, admin }

/// Row tint the Vue data set through `_classes` (`table-success`, `table-danger`).
enum UserHighlight { success, danger }

/// A sample user, shaped like a row of the Vue `UsersData`.
typedef SampleUser = ({
  /// One-based position in the list, used in `/dashboard/users/<id>`.
  int id,
  String username,

  /// Registration day, ISO `yyyy-mm-dd`.
  String registered,
  UserRole role,
  UserStatus status,
  UserHighlight? highlight,
});

/// The 25 sample users of the Vue app.
const sampleUsers = <SampleUser>[
  (
    id: 1,
    username: 'Samppa Nori',
    registered: '2012-01-01',
    role: UserRole.member,
    status: UserStatus.active,
    highlight: null,
  ),
  (
    id: 2,
    username: 'Estavan Lykos',
    registered: '2012-02-01',
    role: UserRole.staff,
    status: UserStatus.banned,
    highlight: null,
  ),
  (
    id: 3,
    username: 'Chetan Mohamed',
    registered: '2012-02-01',
    role: UserRole.admin,
    status: UserStatus.inactive,
    highlight: null,
  ),
  (
    id: 4,
    username: 'Derick Maximinus',
    registered: '2012-03-01',
    role: UserRole.member,
    status: UserStatus.pending,
    highlight: null,
  ),
  (
    id: 5,
    username: 'Friderik Dávid',
    registered: '2012-01-21',
    role: UserRole.staff,
    status: UserStatus.active,
    highlight: null,
  ),
  (
    id: 6,
    username: 'Yiorgos Avraamu',
    registered: '2012-01-01',
    role: UserRole.member,
    status: UserStatus.active,
    highlight: null,
  ),
  (
    id: 7,
    username: 'Avram Tarasios',
    registered: '2012-02-01',
    role: UserRole.staff,
    status: UserStatus.banned,
    highlight: UserHighlight.success,
  ),
  (
    id: 8,
    username: 'Quintin Ed',
    registered: '2012-02-01',
    role: UserRole.admin,
    status: UserStatus.inactive,
    highlight: null,
  ),
  (
    id: 9,
    username: 'Enéas Kwadwo',
    registered: '2012-03-01',
    role: UserRole.member,
    status: UserStatus.pending,
    highlight: null,
  ),
  (
    id: 10,
    username: 'Agapetus Tadeáš',
    registered: '2012-01-21',
    role: UserRole.staff,
    status: UserStatus.active,
    highlight: null,
  ),
  (
    id: 11,
    username: 'Carwyn Fachtna',
    registered: '2012-01-01',
    role: UserRole.member,
    status: UserStatus.active,
    highlight: UserHighlight.success,
  ),
  (
    id: 12,
    username: 'Nehemiah Tatius',
    registered: '2012-02-01',
    role: UserRole.staff,
    status: UserStatus.banned,
    highlight: null,
  ),
  (
    id: 13,
    username: 'Ebbe Gemariah',
    registered: '2012-02-01',
    role: UserRole.admin,
    status: UserStatus.inactive,
    highlight: null,
  ),
  (
    id: 14,
    username: 'Eustorgios Amulius',
    registered: '2012-03-01',
    role: UserRole.member,
    status: UserStatus.pending,
    highlight: null,
  ),
  (
    id: 15,
    username: 'Leopold Gáspár',
    registered: '2012-01-21',
    role: UserRole.staff,
    status: UserStatus.active,
    highlight: null,
  ),
  (
    id: 16,
    username: 'Pompeius René',
    registered: '2012-01-01',
    role: UserRole.member,
    status: UserStatus.active,
    highlight: null,
  ),
  (
    id: 17,
    username: 'Paĉjo Jadon',
    registered: '2012-02-01',
    role: UserRole.staff,
    status: UserStatus.banned,
    highlight: null,
  ),
  (
    id: 18,
    username: 'Micheal Mercurius',
    registered: '2012-02-01',
    role: UserRole.admin,
    status: UserStatus.inactive,
    highlight: null,
  ),
  (
    id: 19,
    username: 'Ganesha Dubhghall',
    registered: '2012-03-01',
    role: UserRole.member,
    status: UserStatus.pending,
    highlight: null,
  ),
  (
    id: 20,
    username: 'Hiroto Šimun',
    registered: '2012-01-21',
    role: UserRole.staff,
    status: UserStatus.active,
    highlight: null,
  ),
  (
    id: 21,
    username: 'Vishnu Serghei',
    registered: '2012-01-01',
    role: UserRole.member,
    status: UserStatus.active,
    highlight: null,
  ),
  (
    id: 22,
    username: 'Zbyněk Phoibos',
    registered: '2012-02-01',
    role: UserRole.staff,
    status: UserStatus.banned,
    highlight: null,
  ),
  (
    id: 23,
    username: 'Einar Randall',
    registered: '2012-02-01',
    role: UserRole.admin,
    status: UserStatus.inactive,
    highlight: UserHighlight.danger,
  ),
  (
    id: 24,
    username: 'Félix Troels',
    registered: '2012-03-21',
    role: UserRole.staff,
    status: UserStatus.active,
    highlight: null,
  ),
  (
    id: 25,
    username: 'Aulus Agmundr',
    registered: '2012-01-01',
    role: UserRole.member,
    status: UserStatus.pending,
    highlight: null,
  ),
];

/// A copy of the users in random order, like the Vue basic tables page (one shuffle per
/// visit). Pass [random] for a repeatable order.
List<SampleUser> shuffledUsers([Random? random]) => [...sampleUsers]..shuffle(random);

/// The registration day of [user] as a UTC date.
DateTime registeredOn(SampleUser user) => DateTime.parse('${user.registered}T00:00:00Z');
