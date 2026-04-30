import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../services/api_client.dart';

class AuthResponse {
  final String token;
  final String role;
  final String email;
  final String? firstName;
  final String? lastName;

  AuthResponse({
    required this.token,
    required this.role,
    required this.email,
    this.firstName,
    this.lastName,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> j) {
    return AuthResponse(
      token: (j['token'] ?? '') as String,
      role: (j['role'] ?? 'USER') as String,
      email: (j['email'] ?? '') as String,
      firstName: j['firstName'] as String?,
      lastName: j['lastName'] as String?,
    );
  }
}

class RegisterResponse {
  final String email;
  final String message;

  RegisterResponse({
    required this.email,
    required this.message,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> j) {
    return RegisterResponse(
      email: (j['email'] ?? '') as String,
      message: (j['message'] ?? '') as String,
    );
  }
}

class AuthService {
  AuthService._();

  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    const path = "/auth/login";
    final url = "${ApiConfig.baseUrl}$path";
    debugPrint('[AuthService][login] POST $url');
    try {
      final res = await ApiClient.dio.post(
        path,
        data: {"email": email, "password": password},
      );
      debugPrint('[AuthService][login] status=${res.statusCode}');
      debugPrint('[AuthService][login] body=${res.data}');
      return AuthResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (error) {
      _logDioError('login', url, error);
      throw Exception(_extractMessage(error));
    } catch (error) {
      debugPrint('[AuthService][login] exception=$error');
      rethrow;
    }
  }

  static Future<RegisterResponse> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    const path = "/auth/register";
    final url = "${ApiConfig.baseUrl}$path";
    debugPrint('[AuthService][register] POST $url');
    try {
      final res = await ApiClient.dio.post(
        path,
        data: {
          "email": email,
          "password": password,
          "firstName": firstName,
          "lastName": lastName,
        },
      );
      debugPrint('[AuthService][register] status=${res.statusCode}');
      debugPrint('[AuthService][register] body=${res.data}');
      return RegisterResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (error) {
      _logDioError('register', url, error);
      throw Exception(_extractMessage(error));
    } catch (error) {
      debugPrint('[AuthService][register] exception=$error');
      rethrow;
    }
  }

  static Future<void> resendVerificationEmail({required String email}) async {
    const path = "/auth/resend-verification";
    final url = "${ApiConfig.baseUrl}$path";
    debugPrint('[AuthService][resendVerification] POST $url');
    try {
      final res = await ApiClient.dio.post(
        path,
        data: {"email": email},
      );
      debugPrint('[AuthService][resendVerification] status=${res.statusCode}');
      debugPrint('[AuthService][resendVerification] body=${res.data}');
    } on DioException catch (error) {
      _logDioError('resendVerification', url, error);
      throw Exception(_extractMessage(error));
    } catch (error) {
      debugPrint('[AuthService][resendVerification] exception=$error');
      rethrow;
    }
  }

  static Future<AuthResponse> updateProfile({
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final res = await ApiClient.dio.post(
        "/auth/profile",
        data: {
          "email": email,
          "firstName": firstName,
          "lastName": lastName,
        },
      );
      return AuthResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
  }

  static Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await ApiClient.dio.post(
        "/auth/change-password",
        data: {
          "email": email,
          "currentPassword": currentPassword,
          "newPassword": newPassword,
        },
      );
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
  }

  static String _extractMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return data;
    }

    return error.message ?? error.toString();
  }

  static void _logDioError(String action, String url, DioException error) {
    debugPrint('[AuthService][$action] request=$url');
    debugPrint('[AuthService][$action] status=${error.response?.statusCode}');
    debugPrint('[AuthService][$action] body=${error.response?.data}');
    debugPrint('[AuthService][$action] exception=$error');
  }
}
