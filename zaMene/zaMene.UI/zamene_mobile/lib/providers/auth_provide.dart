class AuthProvider {
  static String? username;
  static String? password;
  static String? displayName;

  static String? _token;
  static String? get token => _token;
  static set token(String? value) => _token = value;

  static void setToken(String newToken) {
    _token = newToken;
  }
}
