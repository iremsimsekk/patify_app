class AppointmentInstitutionSummary {
  const AppointmentInstitutionSummary({
    required this.id,
    required this.name,
    this.address,
    this.email,
    this.phone,
    this.website,
    this.description,
    this.openingHours,
    this.city,
    this.district,
  });

  final int id;
  final String name;
  final String? address;
  final String? email;
  final String? phone;
  final String? website;
  final String? description;
  final String? openingHours;
  final String? city;
  final String? district;

  factory AppointmentInstitutionSummary.fromJson(Map<String, dynamic> json) {
    return AppointmentInstitutionSummary(
      id: _readInt(json['id']),
      name: (json['name'] ?? '').toString(),
      address: _readNullableString(json['address']),
      email: _readNullableString(json['email']),
      phone: _readNullableString(json['phone']),
      website: _readNullableString(json['website']),
      description: _readNullableString(json['description']),
      openingHours: _readNullableString(json['openingHours']),
      city: _readNullableString(json['city']),
      district: _readNullableString(json['district']),
    );
  }
}

class AppointmentSlot {
  const AppointmentSlot({
    required this.id,
    required this.institutionId,
    required this.institutionName,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.bookedByUserId,
    this.bookedByFirstName,
    this.bookedByLastName,
    this.bookedByEmail,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int institutionId;
  final String institutionName;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final int? bookedByUserId;
  final String? bookedByFirstName;
  final String? bookedByLastName;
  final String? bookedByEmail;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isAvailable => status == 'AVAILABLE';
  bool get isBooked => status == 'BOOKED';
  bool get isCancelled => status == 'CANCELLED';

  String get bookedByFullName {
    final full = [
      bookedByFirstName?.trim(),
      bookedByLastName?.trim(),
    ].whereType<String>().where((value) => value.isNotEmpty).join(' ').trim();
    return full;
  }

  factory AppointmentSlot.fromJson(Map<String, dynamic> json) {
    return AppointmentSlot(
      id: _readInt(json['id']),
      institutionId: _readInt(json['institutionId']),
      institutionName: (json['institutionName'] ?? '').toString(),
      startTime: DateTime.parse((json['startTime'] ?? '').toString()).toLocal(),
      endTime: DateTime.parse((json['endTime'] ?? '').toString()).toLocal(),
      status: (json['status'] ?? 'AVAILABLE').toString(),
      bookedByUserId: _readNullableInt(json['bookedByUserId']),
      bookedByFirstName: _readNullableString(json['bookedByFirstName']),
      bookedByLastName: _readNullableString(json['bookedByLastName']),
      bookedByEmail: _readNullableString(json['bookedByEmail']),
      note: _readNullableString(json['note']),
      createdAt: _readNullableDateTime(json['createdAt']),
      updatedAt: _readNullableDateTime(json['updatedAt']),
    );
  }
}

class VeterinarianAppointmentSummary {
  const VeterinarianAppointmentSummary({
    required this.date,
    required this.totalSlots,
    required this.availableSlots,
    required this.bookedSlots,
    required this.cancelledSlots,
  });

  final DateTime date;
  final int totalSlots;
  final int availableSlots;
  final int bookedSlots;
  final int cancelledSlots;

  factory VeterinarianAppointmentSummary.fromJson(Map<String, dynamic> json) {
    return VeterinarianAppointmentSummary(
      date: DateTime.parse((json['date'] ?? '').toString()),
      totalSlots: _readInt(json['totalSlots']),
      availableSlots: _readInt(json['availableSlots']),
      bookedSlots: _readInt(json['bookedSlots']),
      cancelledSlots: _readInt(json['cancelledSlots']),
    );
  }
}

class VeterinarianDaySlots {
  const VeterinarianDaySlots({
    required this.institution,
    required this.summary,
    required this.slots,
  });

  final AppointmentInstitutionSummary? institution;
  final VeterinarianAppointmentSummary summary;
  final List<AppointmentSlot> slots;

  factory VeterinarianDaySlots.fromJson(Map<String, dynamic> json) {
    return VeterinarianDaySlots(
      institution: json['institution'] is Map<String, dynamic>
          ? AppointmentInstitutionSummary.fromJson(
              json['institution'] as Map<String, dynamic>,
            )
          : null,
      summary: VeterinarianAppointmentSummary.fromJson(
        json['summary'] as Map<String, dynamic>,
      ),
      slots: ((json['slots'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AppointmentSlot.fromJson)
          .toList(growable: false),
    );
  }
}

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _readNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

String? _readNullableString(dynamic value) {
  if (value == null) return null;
  final normalized = value.toString().trim();
  return normalized.isEmpty ? null : normalized;
}

DateTime? _readNullableDateTime(dynamic value) {
  final text = _readNullableString(value);
  if (text == null) return null;
  return DateTime.tryParse(text)?.toLocal();
}
