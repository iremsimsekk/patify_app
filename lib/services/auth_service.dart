import '../services/api_client.dart';

class AuthResponse {
  final String token;
  final String role;

  // ✅ yeni alanlar
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
    final res = await ApiClient.dio.post(
      "/auth/login",
      data: {"email": email, "password": password},
    );
    return AuthResponse.fromJson(res.data as Map<String, dynamic>);
  }

  static Future<AuthResponse> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
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
  }
}
