class AdminUserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? profileImage;
  final String? phone;

  AdminUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.profileImage,
    this.phone,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    String parseId(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    String parseString(dynamic value, {String fallback = ''}) {
      if (value == null) return fallback;
      return value.toString();
    }

    bool parseActive(dynamic value) {
      if (value == null) return true;
      if (value is bool) return value;
      return value.toString().toLowerCase() == 'true';
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      try {
        if (value is String) return DateTime.parse(value);
        if (value is DateTime) return value;
      } catch (_) {}
      return null;
    }

    return AdminUserModel(
      id: parseId(json['_id'] ?? json['id']),
      name: parseString(json['name'], fallback: 'Unknown'),
      email: parseString(json['email']),
      role: parseString(json['role'], fallback: 'user').toLowerCase(),
      isActive: parseActive(json['isActive'] ?? json['active']),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      profileImage: parseString(json['profileImage'] ?? json['avatar']),
      phone: parseString(json['phone']),
    );
  }

  /* Helper getter to determine if user is admin */
  bool get isAdmin => role.toLowerCase() == 'admin';

  /* Helper getter for display name with email fallback */
  String get displayName => name.isNotEmpty ? name : email;
}
