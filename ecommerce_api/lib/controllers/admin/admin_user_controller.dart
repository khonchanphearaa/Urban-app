import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/api_constants.dart';
import '../../models/admin_user_model.dart';
import '../../services/secure_storage_service.dart';

class AdminUserController extends ChangeNotifier {
  List<AdminUserModel> _users = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _limit = 10;
  int _total = 0;
  int _totalPages = 1;

  List<AdminUserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get limit => _limit;
  int get total => _total;
  int get totalPages => _totalPages;

  /* Getters for statistics */
  int get totalAdmins => _users.where((u) => u.isAdmin).length;
  int get totalActiveUsers => _users.where((u) => u.isActive).length;

  Future<String?> _getToken() async {
    return await SecureStorageService.readToken();
  }

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  int _safeTotalPages(int total, int limit) {
    if (limit <= 0) return 1;
    final pages = (total / limit).ceil();
    return pages < 1 ? 1 : pages;
  }

  /* Fetch all users with pagination */
  Future<void> fetchUsers({int page = 1, int? limit}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (limit != null && limit > 0) {
        _limit = limit;
      }

      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Not authenticated. Please login again.');
      }

      final query = {'page': page.toString(), 'limit': _limit.toString()};

      final response = await http.get(
        Uri.parse(
          '${ApiConstants.apiBaseUrl}/auth/list-users',
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dynamic dataField = data['data'];
        final List<dynamic> safeUsers = dataField is List
            ? List<dynamic>.from(dataField)
            : (data['users'] is List
                  ? List<dynamic>.from(data['users'])
                  : <dynamic>[]);

        _users = safeUsers
            .whereType<Map>()
            .map(
              (json) =>
                  AdminUserModel.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();

        _currentPage = _toInt(data['page'], fallback: page);
        _limit = _toInt(data['limit'], fallback: _limit);
        _total = _toInt(
          data['total'],
          fallback: _toInt(data['count'], fallback: _users.length),
        );
        _totalPages = _toInt(
          data['totalPages'],
          fallback: _safeTotalPages(_total, _limit),
        );

        if (_totalPages < 1) {
          _totalPages = 1;
        }

        _error = null;
      } else {
        _error = 'Failed to load users: ${response.body}';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /* Update user role (admin/user) */
  Future<bool> updateUserRole({
    required String userId,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.patch(
        Uri.parse('${ApiConstants.apiBaseUrl}/auth/users/$userId/role'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'role': role}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _error = null;
        /* Refresh current page */
        await fetchUsers(page: _currentPage);
        return true;
      } else {
        _error = 'Failed to update user role: ${response.body}';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /* Deactivate/activate user */
  Future<bool> toggleUserStatus({
    required String userId,
    required bool isActive,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.patch(
        Uri.parse('${ApiConstants.apiBaseUrl}/auth/users/$userId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'isActive': isActive}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _error = null;
        /* Refresh current page */
        await fetchUsers(page: _currentPage);
        return true;
      } else {
        _error = 'Failed to update user status: ${response.body}';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /* Delete user */
  Future<bool> deleteUser({required String userId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.delete(
        Uri.parse('${ApiConstants.apiBaseUrl}/auth/users/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _error = null;
        /* Refresh current page */
        await fetchUsers(page: _currentPage);
        return true;
      } else {
        _error = 'Failed to delete user: ${response.body}';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /* Go to next page */
  void nextPage() {
    if (_currentPage < _totalPages) {
      fetchUsers(page: _currentPage + 1);
    }
  }

  /* Go to previous page */
  void previousPage() {
    if (_currentPage > 1) {
      fetchUsers(page: _currentPage - 1);
    }
  }

  /* Go to specific page */
  void goToPage(int page) {
    if (page > 0 && page <= _totalPages && page != _currentPage) {
      fetchUsers(page: page);
    }
  }
}
