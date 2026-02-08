class LocalUser {
  final String email;
  final String password;

  LocalUser({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };

  static LocalUser fromJson(Map<String, dynamic> json) {
    return LocalUser(
      email: json['email'],
      password: json['password'],
    );
  }
}
