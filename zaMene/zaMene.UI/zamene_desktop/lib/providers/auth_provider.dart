class AuthProvider {
  static String? username;
  static String? password;
  static String? displayName;
  static List<String> roles = [];

  static String? _token;
  static String? get token => _token;
  static set token(String? value) => _token = value;

  static void setToken(String newToken) {
    _token = newToken;
  }

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
