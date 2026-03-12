class NotificationAlertModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;

  NotificationAlertModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NotificationAlertModel.fromJson(Map<String, dynamic> json) {
    return NotificationAlertModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'info',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
