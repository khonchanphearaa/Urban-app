class UserModel {
  final String? id;
  final String? name;
  final String email;
  final String? token;
  final String? role;
  final String? avatar;

  UserModel({
    this.id,
    this.name,
    required this.email,
    this.token,
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

    return UserModel(
      id: id,
      name: name,
      email: email,
      token: token,
      role: role,
      avatar: avatar,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
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
