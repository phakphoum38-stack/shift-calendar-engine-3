import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../features/auth/infrastructure/token_store.dart';
import 'api_configuration.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({
    required this._configuration,
    required this._tokenStore,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final ApiConfiguration _configuration;
  final TokenStore _tokenStore;
  final http.Client _httpClient;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool authenticated = true,
  }) async {
    final response = await _httpClient.get(
      _configuration.resolve(path, queryParameters),
      headers: await _headers(authenticated: authenticated),
    );

    return _decode(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final response = await _httpClient.post(
      _configuration.resolve(path),
      headers: await _headers(authenticated: authenticated),
      body: jsonEncode(body ?? const <String, dynamic>{}),
    );

    return _decode(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final response = await _httpClient.put(
      _configuration.resolve(path),
      headers: await _headers(authenticated: authenticated),
      body: jsonEncode(body ?? const <String, dynamic>{}),
    );

    return _decode(response);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    bool authenticated = true,
  }) async {
    final response = await _httpClient.delete(
      _configuration.resolve(path),
      headers: await _headers(authenticated: authenticated),
    );

    return _decode(response);
  }

  Future<Map<String, String>> _headers({required bool authenticated}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (authenticated) {
      final token = await _tokenStore.read();

      if (token != null && token.trim().isNotEmpty) {
        headers['Authorization'] = 'Bearer ${token.trim()}';
      }
    }

    return headers;
  }

  Map<String, dynamic> _decode(http.Response response) {
    Object? decodedBody;

    if (response.body.trim().isNotEmpty) {
      try {
        decodedBody = jsonDecode(response.body);
      } on FormatException {
        decodedBody = response.body;
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      var message = 'API request failed.';

      if (decodedBody is Map) {
        final mappedBody = Map<String, dynamic>.from(decodedBody);
        message = mappedBody['message']?.toString() ?? message;
      }

      throw ApiException(
        message: message,
        statusCode: response.statusCode,
        body: decodedBody,
      );
    }

    if (decodedBody == null) {
      return const <String, dynamic>{};
    }

    if (decodedBody is Map) {
      return Map<String, dynamic>.from(decodedBody);
    }

    throw ApiException(
      message: 'The API returned an unexpected response.',
      statusCode: response.statusCode,
      body: decodedBody,
    );
  }

  void close() {
    _httpClient.close();
  }
}
