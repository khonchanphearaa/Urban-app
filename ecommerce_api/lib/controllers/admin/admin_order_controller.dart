import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/api_constants.dart';
import '../../models/order_model.dart';
import '../../services/secure_storage_service.dart';

class AdminOrderController extends ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _limit = 10;
  int _total = 0;
  int _totalPages = 1;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get limit => _limit;
  int get total => _total;
  int get totalPages => _totalPages;

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

  /* Fetch orders with pagination */
  Future<void> fetchOrders({int page = 1, int? limit}) async {
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
          '${ApiConstants.apiBaseUrl}/orders/admin',
        ).replace(queryParameters: query),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dynamic dataField = data['data'];
        final List<dynamic> safeOrders = dataField is List
            ? List<dynamic>.from(dataField)
            : (data['orders'] is List
                  ? List<dynamic>.from(data['orders'])
                  : <dynamic>[]);

        _orders = safeOrders
            .whereType<Map>()
            .map((json) => OrderModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        _currentPage = _toInt(data['page'], fallback: page);
        _limit = _toInt(data['limit'], fallback: _limit);
        _total = _toInt(
          data['total'],
          fallback: _toInt(data['count'], fallback: _orders.length),
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
        _error = 'Failed to load orders: ${response.body}';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /* Update order status (optional admin feature) */
  Future<bool> updateOrderStatus({
    required String orderId,
    required String status,
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
        Uri.parse('${ApiConstants.apiBaseUrl}/admin/orders/$orderId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _error = null;

        /* Refresh current page */
        await fetchOrders(page: _currentPage);
        return true;
      } else {
        _error = 'Failed to update order status: ${response.body}';
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
      fetchOrders(page: _currentPage + 1);
    }
  }

  /* Go to previous page */
  void previousPage() {
    if (_currentPage > 1) {
      fetchOrders(page: _currentPage - 1);
    }
  }

  /* Go to specific page */
  void goToPage(int page) {
    if (page > 0 && page <= _totalPages && page != _currentPage) {
      fetchOrders(page: page);
    }
  }
}
