import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_endpoints.dart';

// 1. Create a Provider for the Dio instance
// This allows other providers to use the same configuration
final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30), // Increased for Render.com
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
});