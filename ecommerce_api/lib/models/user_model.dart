class UserModel {
  final String? id;
  final String? name;
  final String email;
  final String? token;
  final String? refreshToken;
  final String? role;
  final String? avatar;

  UserModel({
    this.id,
    this.name,
    required this.email,
    this.token,
    this.refreshToken,
    this.role,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle several possible API response shapes, e.g.:
    // { user: { _id, name, email, role }, token }
    // { data: { user: {...}, token } }
    // { user: {...}, access_token }
    // or the user object itself at top-level

    Map<String, dynamic> map = json;
    if (json['data'] is Map<String, dynamic>) {
      map = json['data'] as Map<String, dynamic>;
    }

    final dynamic userObj = map['user'] ?? map;

    final String email = (userObj is Map && userObj['email'] != null)
        ? userObj['email'] as String
        : '';

    final String? id = (userObj is Map)
        ? (userObj['_id'] ?? userObj['id']) as String?
        : null;

    final String? name = (userObj is Map) ? userObj['name'] as String? : null;

    final String? role = (userObj is Map) ? userObj['role'] as String? : null;

    String? avatar;
    if (userObj is Map) {
      final rawAvatar =
          userObj['avatar'] ?? userObj['avatarUrl'] ?? userObj['profileImage'];
      if (rawAvatar is String) {
        avatar = rawAvatar;
      } else if (rawAvatar is Map) {
        avatar = (rawAvatar['url'] ?? rawAvatar['secure_url']) as String?;
      }
    }

    /* token may appear in several places / names (include camelCase 'accessToken') */
    String? token;
    token =
        json['token'] as String? ??
        json['access_token'] as String? ??
        json['accessToken'] as String?;
    token ??=
        map['token'] as String? ??
        map['access_token'] as String? ??
        map['accessToken'] as String?;

    String? refreshToken;
    refreshToken =
        json['refresh_token'] as String? ??
        json['refreshToken'] as String?;
    refreshToken ??=
        map['refresh_token'] as String? ??
        map['refreshToken'] as String?;

    return UserModel(
      id: id,
      name: name,
      email: email,
      token: token,
      refreshToken: refreshToken,
      role: role,
      avatar: avatar,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? token,
    String? refreshToken,
    String? role,
    String? avatar,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'refreshToken': refreshToken,
      'role': role,
      'avatar': avatar,
    };
  }

  /* Returns headers including `Authorization` when token is available. */
  Map<String, String> authHeaders() {
    if (token == null) return {};
    return {'Authorization': 'Bearer $token'};
  }
}
