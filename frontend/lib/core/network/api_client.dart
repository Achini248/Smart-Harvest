// lib/core/network/api_client.dart
// Smart Harvest — HTTP client that injects the Firebase ID token automatically.
// All routes protected by @firebase_auth_required will be authenticated this way.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

class ApiClient {
  ApiClient._internal();
  static final ApiClient instance = ApiClient._internal();

  final http.Client _client = http.Client();

  // ── Token ──────────────────────────────────────────────────────────────────
  /// Returns a fresh Firebase ID token, or null if not signed in.
  Future<String?> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return user.getIdToken(); // auto-refreshes when expired
  }

  Future<Map<String, String>> _headers() async {
    final token = await _getIdToken();
    return {
      'Content-Type': 'application/json',
      'Accept':       'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── GET ────────────────────────────────────────────────────────────────────
  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$path')
          .replace(queryParameters: queryParams);
      final response = await _client
          .get(uri, headers: await _headers())
          .timeout(ApiConstants.timeout);
      return _handle(response);
    } on SocketException {
      throw const NetworkException(message: 'No internet connection.');
    } on TimeoutException {
      throw const NetworkException(message: 'Request timed out.');
    } on FormatException {
      throw const ServerException(message: 'Invalid server response format.');
    }
  }

  // ── POST ───────────────────────────────────────────────────────────────────
  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConstants.baseUrl}$path'),
            headers: await _headers(),
            body:    jsonEncode(body),
          )
          .timeout(ApiConstants.timeout);
      return _handle(response);
    } on SocketException {
      throw const NetworkException(message: 'No internet connection.');
    } on TimeoutException {
      throw const NetworkException(message: 'Request timed out.');
    }
  }

  // ── PUT ────────────────────────────────────────────────────────────────────
  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    try {
      final response = await _client
          .put(
            Uri.parse('${ApiConstants.baseUrl}$path'),
            headers: await _headers(),
            body:    jsonEncode(body),
          )
          .timeout(ApiConstants.timeout);
      return _handle(response);
    } on SocketException {
      throw const NetworkException(message: 'No internet connection.');
    }
  }

  // ── Response handler ──────────────────────────────────────────────────────
  dynamic _handle(http.Response response) {
    final bodyStr = utf8.decode(response.bodyBytes);
    final json    = jsonDecode(bodyStr) as Map<String, dynamic>;

    switch (response.statusCode) {
      case 200:
      case 201:
        // Backend wraps in { "success": true, "data": ... }
        return json.containsKey('data') ? json['data'] : json;
      case 401:
        throw const AuthException(message: 'Session expired. Please log in again.');
      case 403:
        throw const AuthException(message: 'Access denied.');
      case 404:
        throw const ServerException(message: 'Resource not found.');
      case 422:
        throw ServerException(message: json['error'] ?? 'Validation error.');
      case 500:
        throw ServerException(message: json['error'] ?? 'Server error. Please try again.');
      default:
        throw ServerException(
          message: json['error'] ?? 'Unexpected error (${response.statusCode}).',
        );
    }
  }

  void dispose() => _client.close();
}
