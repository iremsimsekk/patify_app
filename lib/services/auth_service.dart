import 'package:dio/dio.dart';

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

class AuthService {
  AuthService._();

  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await ApiClient.dio.post(
        "/auth/login",
        data: {"email": email, "password": password},
      );
      return AuthResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
  }

  static Future<AuthResponse> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final res = await ApiClient.dio.post(
        "/auth/register",
        data: {
          "email": email,
          "password": password,
          "firstName": firstName,
          "lastName": lastName,
        },
      );
      return AuthResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
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
}
