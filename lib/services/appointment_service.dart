import 'package:dio/dio.dart';

import '../models/appointment_slot.dart';
import 'api_client.dart';
import 'app_preferences.dart';

class AppointmentService {
  AppointmentService._();

  static Future<VeterinarianDaySlots> fetchVeterinarianSlots({
    required DateTime date,
  }) async {
    try {
      final res = await ApiClient.dio.get(
        '/api/veterinarian/appointments/slots',
        queryParameters: {'date': _formatDate(date)},
        options: await _authorizedOptions(),
      );
      return VeterinarianDaySlots.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
  }

  static Future<VeterinarianAppointmentSummary> fetchVeterinarianSummary({
    required DateTime date,
  }) async {
    try {
      final res = await ApiClient.dio.get(
        '/api/veterinarian/appointments/summary',
        queryParameters: {'date': _formatDate(date)},
        options: await _authorizedOptions(),
      );
      return VeterinarianAppointmentSummary.fromJson(
        res.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
  }

  static Future<VeterinarianMonthSummary> fetchVeterinarianMonthSummary({
    required DateTime month,
  }) async {
    try {
      final res = await ApiClient.dio.get(
        '/api/veterinarian/appointments/summary',
        queryParameters: {'month': _formatMonth(month)},
        options: await _authorizedOptions(),
      );
      return VeterinarianMonthSummary.fromJson(
        res.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
  }

  static Future<BulkSlotCreateResult> createBulkSlots({
    required DateTime date,
    required String startTime,
    required String endTime,
    required int slotDurationMinutes,
    String? note,
  }) async {
    try {
      final res = await ApiClient.dio.post(
        '/api/veterinarian/appointments/slots/bulk',
        data: {
          'date': _formatDate(date),
          'startTime': startTime,
          'endTime': endTime,
          'slotDurationMinutes': slotDurationMinutes,
          if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        },
        options: await _authorizedOptions(),
      );
      return BulkSlotCreateResult.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
  }

  static Future<AppointmentSlot> cancelVeterinarianSlot(int slotId) async {
    try {
      final res = await ApiClient.dio.patch(
        '/api/veterinarian/appointments/slots/$slotId/cancel',
        options: await _authorizedOptions(),
      );
      return AppointmentSlot.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
  }

  static Future<AppointmentSlot> cancelVeterinarianBookedSlot({
    required int slotId,
    required String reason,
  }) async {
    try {
      final res = await ApiClient.dio.patch(
        '/api/veterinarian/appointments/slots/$slotId/cancel-booked',
        data: {
          'reason': reason.trim(),
        },
        options: await _authorizedOptions(),
      );
      return AppointmentSlot.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
  }

  static Future<List<AppointmentSlot>> fetchAvailableSlots({
    required int institutionId,
    required DateTime date,
  }) async {
    try {
      final res = await ApiClient.dio.get(
        '/api/appointments/veterinarians/$institutionId/available-slots',
        queryParameters: {'date': _formatDate(date)},
      );
      final rows = (res.data as List).cast<Map<String, dynamic>>();
      return rows.map(AppointmentSlot.fromJson).toList(growable: false);
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
  }

  static Future<AppointmentAvailabilityStatus> fetchAvailabilityStatus({
    required int institutionId,
  }) async {
    try {
      final res = await ApiClient.dio.get(
        '/api/appointments/veterinarians/$institutionId/availability-status',
      );
      return AppointmentAvailabilityStatus.fromJson(
        res.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
  }

  static Future<AppointmentSlot> bookSlot(int slotId) async {
    try {
      final res = await ApiClient.dio.post(
        '/api/appointments/slots/$slotId/book',
        options: await _authorizedOptions(),
      );
      return AppointmentSlot.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
  }

  static Future<List<AppointmentSlot>> fetchMyAppointments() async {
    try {
      final res = await ApiClient.dio.get(
        '/api/appointments/my',
        options: await _authorizedOptions(),
      );
      final rows = (res.data as List).cast<Map<String, dynamic>>();
      return rows.map(AppointmentSlot.fromJson).toList(growable: false);
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
  }

  static Future<AppointmentSlot> cancelMyBooking(int slotId) async {
    try {
      final res = await ApiClient.dio.patch(
        '/api/appointments/slots/$slotId/cancel-booking',
        options: await _authorizedOptions(),
      );
      return AppointmentSlot.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_extractMessage(error));
    }
  }

  static Future<Options> _authorizedOptions() async {
    final token = await AppPreferences.loadAuthToken();
    if (token == null || token.trim().isEmpty) {
      throw Exception('AUTH_TOKEN_MISSING');
    }
    return Options(
      headers: {
        'Authorization': 'Bearer ${token.trim()}',
      },
    );
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

  static String _formatDate(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  static String _formatMonth(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    return '${local.year}-$month';
  }
}
