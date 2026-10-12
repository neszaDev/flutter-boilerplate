/// Roles the backend knows (`user/Role` in the Spring API), sent as `"USER"` / `"ADMIN"`.
///
/// To add a role: add it here with its API name, give it permissions in `access_policy.dart`,
/// and add its label to `AccountPage.role_<NAME>` in every `l10n/<locale>/users.json`.
enum Role {
  user('USER'),
  admin('ADMIN');

  const Role(this.apiName);

  /// The value the backend sends and accepts.
  final String apiName;

  /// Parses the backend's value. Unknown values (a role added on the backend before the app
  /// knows it) return null and get only the permissions every signed-in account has.
  static Role? fromApi(String? value) {
    for (final role in values) {
      if (role.apiName == value) {
        return role;
      }
    }
    return null;
  }
}
