class AuthUser {
  const AuthUser({required this.id, required this.name, required this.email});

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  final String id;
  final String name;
  final String email;
}

class AuthSession {
  const AuthSession({
    required this.tokenType,
    required this.accessToken,
    required this.abilities,
    required this.user,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final rawAbilities = json['abilities'];

    return AuthSession(
      tokenType: json['tokenType']?.toString() ?? 'Bearer',
      accessToken: json['accessToken']?.toString() ?? '',
      abilities: rawAbilities is List
          ? rawAbilities.map((item) => item.toString()).toList(growable: false)
          : const <String>[],
      user: AuthUser.fromJson(
        Map<String, dynamic>.from(json['user'] as Map? ?? const {}),
      ),
    );
  }

  final String tokenType;
  final String accessToken;
  final List<String> abilities;
  final AuthUser user;

  bool can(String ability) {
    return abilities.contains(ability);
  }
}
