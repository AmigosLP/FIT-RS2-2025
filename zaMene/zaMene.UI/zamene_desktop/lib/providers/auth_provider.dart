class AuthProvider {
  static String? username;
  static String? password;
  static String? displayName;
  static List<String> roles = [];

  static bool isAdmin() {
    return roles.contains("Admin");
  }

  static void clear() {
    username = null;
    password = null;
    displayName = null;
    roles = [];
  }
}
