import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';

class ApiResponse<T> {
  final bool success;
  final int code;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.code,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] == true,
      code: json['code'] is int ? json['code'] : 200,
      message: json['message']?.toString() ?? '',
      data: (json['data'] != null && fromJsonT != null)
          ? fromJsonT(json['data'])
          : json['data'] as T?,
    );
  }
}

class ApiClient {
  final http.Client _client = http.Client();

  /// Execute POST action against Google Apps Script Web App.
  Future<ApiResponse<dynamic>> postAction({
    required String action,
    String? sessionToken,
    Map<String, dynamic>? payload,
  }) async {
    try {
      final requestBody = {
        'action': action,
        'session_token': sessionToken,
        'payload': payload ?? {},
      };

      final response = await _client
          .post(
            Uri.parse(ApiEndpoints.activeBaseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 40));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse.fromJson(decoded, (d) => d);
      } else if (response.statusCode == 302) {
        // Handle Google Apps Script 302 Redirect
        final redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
          final redirectedResponse = await _client.get(Uri.parse(redirectUrl));
          final decoded =
              jsonDecode(redirectedResponse.body) as Map<String, dynamic>;
          return ApiResponse.fromJson(decoded, (d) => d);
        }
      }

      return ApiResponse(
        success: false,
        code: response.statusCode,
        message: 'Server returned HTTP ${response.statusCode}',
      );
    } on SocketException {
      return ApiResponse(
        success: false,
        code: 503,
        message: 'Network offline. Please check your internet connection.',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        code: 500,
        message: e.toString(),
      );
    }
  }

  /// Execute GET action (Public Home Cache, Ping).
  Future<ApiResponse<dynamic>> getAction(String action) async {
    try {
      final uri = Uri.parse(ApiEndpoints.activeBaseUrl)
          .replace(queryParameters: {'action': action});
      final response = await _client.get(uri).timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse.fromJson(decoded, (d) => d);
      }
      return ApiResponse(
        success: false,
        code: response.statusCode,
        message: 'Server error: ${response.statusCode}',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        code: 500,
        message: e.toString(),
      );
    }
  }
}
