class LocalUser {
  final String email;
  final String password;
  final String? displayName;
  final String? photoUrl;
  final String authProvider; // 'email' o 'google'

  LocalUser({
    required this.email,
    this.password = '',
    this.displayName,
    this.photoUrl,
    this.authProvider = 'email',
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'authProvider': authProvider,
      };

  static LocalUser fromJson(Map<String, dynamic> json) {
    return LocalUser(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      authProvider: json['authProvider'] ?? 'email',
    );
  }
}
