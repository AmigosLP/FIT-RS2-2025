class UserRegisterModel {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String username;
  final String gender;
  final String? phone;

  UserRegisterModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.username,
    required this.gender,
    required this.phone
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'username': username,
        'gender': gender,
        'phone': phone
      };
}
