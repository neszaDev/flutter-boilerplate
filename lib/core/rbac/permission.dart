/// Everything a screen or action can be gated on. Screens ask for a permission, never for a
/// role: which roles hold which permission lives in one place (`access_policy.dart`), so a new
/// role or a changed rule is a one-line change instead of a hunt through the widgets.
///
/// Name permissions `<verb><Resource>` after what the user does. The backend enforces the same
/// rules (its 403 is the source of truth); these only decide what the app shows.
enum Permission {
  /// The overview tab.
  viewDashboard,

  /// Create, edit and delete your own test results.
  manageOwnTestResults,

  /// Upload, download and delete your own files.
  manageOwnFiles,

  /// See your own account details.
  viewOwnAccount,

  /// The phone features demos (biometrics, sensors, camera…).
  useDeviceFeatures,

  /// The component showcase and sample apps.
  viewShowcase,

  /// List and open other users' accounts (`GET /users`, `GET /users/{id}`).
  viewUsers,

  /// Change other users' email and role (`PATCH /users/{id}`).
  editUsers,

  /// Delete other users with their data (`DELETE /users/{id}`).
  deleteUsers,
}
