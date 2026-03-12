import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'notification_alert_model.dart';

class NotificationAlertStorage {
  static const _alertsKey = 'urban_notifications_alerts';
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static Future<List<NotificationAlertModel>> readAlerts() async {
    final raw = await _storage.read(key: _alertsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(NotificationAlertModel.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveAlert(NotificationAlertModel alert) async {
    final current = await readAlerts();
    final updated = [alert, ...current];
    await _storage.write(
      key: _alertsKey,
      value: jsonEncode(updated.map((entry) => entry.toJson()).toList()),
    );
  }

  static Future<void> clearAlerts() async {
    await _storage.delete(key: _alertsKey);
  }
}
