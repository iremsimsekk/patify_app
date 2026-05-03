import 'package:dio/dio.dart';

import 'api_client.dart';

class LostReport {
  const LostReport({
    required this.id,
    required this.status,
    required this.notificationSent,
    required this.isApproved,
    required this.notificationEligible,
    required this.notificationRecipientCount,
    required this.district,
    required this.imageUrl,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.petType,
    required this.description,
    required this.contactInfo,
    required this.canMarkFound,
    required this.message,
  });

  final int id;
  final String status;
  final bool notificationSent;
  final bool isApproved;
  final bool notificationEligible;
  final int notificationRecipientCount;
  final String? district;
  final String? imageUrl;
  final String? address;
  final double latitude;
  final double longitude;
  final String petType;
  final String description;
  final String contactInfo;
  final bool canMarkFound;
  final String message;

  factory LostReport.fromJson(Map<String, dynamic> json) {
    return LostReport(
      id: (json['id'] as num).toInt(),
      status: (json['status'] ?? '') as String,
      notificationSent: (json['notificationSent'] ?? false) as bool,
      isApproved: (json['isApproved'] ?? false) as bool,
      notificationEligible: (json['notificationEligible'] ?? false) as bool,
      notificationRecipientCount:
          (json['notificationRecipientCount'] as num? ?? 0).toInt(),
      district: json['district'] as String?,
      imageUrl: json['imageUrl'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num? ?? 0).toDouble(),
      longitude: (json['longitude'] as num? ?? 0).toDouble(),
      petType: (json['petType'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      contactInfo: (json['contactInfo'] ?? '') as String,
      canMarkFound: (json['canMarkFound'] ?? false) as bool,
      message: (json['message'] ?? '') as String,
    );
  }
}

class LostReportNotification {
  const LostReportNotification({
    required this.id,
    required this.lostReportId,
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
  });

  final int id;
  final int lostReportId;
  final String title;
  final String message;
  final bool read;
  final DateTime? createdAt;

  factory LostReportNotification.fromJson(Map<String, dynamic> json) {
    return LostReportNotification(
      id: (json['id'] as num).toInt(),
      lostReportId: (json['lostReportId'] as num).toInt(),
      title: (json['title'] ?? '') as String,
      message: (json['message'] ?? '') as String,
      read: (json['read'] ?? false) as bool,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '') as String),
    );
  }
}

class LostReportService {
  LostReportService._();

  static Future<LostReport> create({
    required String userEmail,
    required String petType,
    required String description,
    required String contactInfo,
    required String district,
    required String address,
    required double latitude,
    required double longitude,
    String? imageUrl,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/lost-reports',
        data: {
          'userEmail': userEmail,
          'petType': petType,
          'description': description,
          'imageUrl': imageUrl,
          'latitude': latitude,
          'longitude': longitude,
          'seenAt': DateTime.now().toUtc().toIso8601String(),
          'contactInfo': contactInfo,
          'district': district,
          'address': address,
        },
      );
      return LostReport.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
  }

  static Future<List<LostReportNotification>> notifications({
    required String email,
    bool unreadOnly = false,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        '/lost-reports/notifications',
        queryParameters: {'email': email, 'unreadOnly': unreadOnly},
      );
      final items = response.data as List<dynamic>;
      return items
          .map((item) =>
              LostReportNotification.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
  }

  static Future<List<LostReport>> activeReports({
    required String email,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        '/lost-reports',
        queryParameters: {'email': email},
      );
      final items = response.data as List<dynamic>;
      return items
          .map((item) => LostReport.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
  }

  static Future<void> markNotificationRead({
    required int id,
    required String email,
  }) async {
    try {
      await ApiClient.dio.post(
        '/lost-reports/notifications/$id/read',
        queryParameters: {'email': email},
      );
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
  }

  static Future<LostReport> detail({
    required int id,
    required String email,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        '/lost-reports/$id',
        queryParameters: {'email': email},
      );
      return LostReport.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
  }

  static Future<LostReport> markFound({
    required int id,
    required String email,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/lost-reports/$id/found',
        queryParameters: {'email': email},
      );
      return LostReport.fromJson(response.data as Map<String, dynamic>);
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
