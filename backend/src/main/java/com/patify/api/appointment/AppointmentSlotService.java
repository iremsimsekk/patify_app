package com.patify.api.appointment;

import com.patify.api.auth.AuthContextService;
import com.patify.api.auth.EmailService;
import com.patify.api.auth.Role;
import com.patify.api.auth.User;
import com.patify.api.institution.Institution;
import com.patify.api.veterinarian.VeterinaryClaimRequest;
import com.patify.api.veterinarian.VeterinaryClaimRequestRepository;
import com.patify.api.veterinarian.VeterinaryClaimStatus;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.OffsetDateTime;
import java.time.YearMonth;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class AppointmentSlotService {
  private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("HH:mm");
  private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd.MM.yyyy");
  private static final List<Integer> ALLOWED_SLOT_DURATIONS = List.of(15, 30, 45, 60);

  private final AppointmentSlotRepository appointmentSlots;
  private final VeterinaryClaimRequestRepository claimRequests;
  private final AuthContextService authContextService;
  private final EmailService emailService;

  public AppointmentSlotService(
      AppointmentSlotRepository appointmentSlots,
      VeterinaryClaimRequestRepository claimRequests,
      AuthContextService authContextService,
      EmailService emailService
  ) {
    this.appointmentSlots = appointmentSlots;
    this.claimRequests = claimRequests;
    this.authContextService = authContextService;
    this.emailService = emailService;
  }

  public VeterinarianDaySlotsResponse getVeterinarianSlots(
      String authorizationHeader,
      LocalDate date
  ) {
    VeterinaryContext context = requireApprovedVeterinarianContext(authorizationHeader);
    List<AppointmentSlot> slots = appointmentSlots
        .findAllByVeterinarianIdAndStartTimeBetweenOrderByStartTimeAsc(
            context.user().id,
            startOfDay(date),
            startOfDay(date.plusDays(1))
        );
    return new VeterinarianDaySlotsResponse(
        toInstitutionResponse(context.institution()),
        toSummary(slots, date),
        toSlotResponses(slots, true)
    );
  }

  public VeterinarianSummaryResponse getVeterinarianSummary(
      String authorizationHeader,
      LocalDate date
  ) {
    VeterinaryContext context = requireApprovedVeterinarianContext(authorizationHeader);
    List<AppointmentSlot> slots = appointmentSlots
        .findAllByVeterinarianIdAndStartTimeBetweenOrderByStartTimeAsc(
            context.user().id,
            startOfDay(date),
            startOfDay(date.plusDays(1))
        );
    return toSummary(slots, date);
  }

  public VeterinarianMonthSummaryResponse getVeterinarianMonthSummary(
      String authorizationHeader,
      YearMonth month
  ) {
    VeterinaryContext context = requireApprovedVeterinarianContext(authorizationHeader);
    OffsetDateTime rangeStart = startOfDay(month.atDay(1));
    OffsetDateTime rangeEnd = startOfDay(month.plusMonths(1).atDay(1));
    List<AppointmentSlot> slots = appointmentSlots
        .findAllByVeterinarianIdAndStartTimeBetweenOrderByStartTimeAsc(
            context.user().id,
            rangeStart,
            rangeEnd
        );

    List<CalendarDaySummaryResponse> days = month.atDay(1).datesUntil(month.plusMonths(1).atDay(1))
        .map(day -> {
          List<AppointmentSlot> dailySlots = slots.stream()
              .filter(slot -> slot.getStartTime().toLocalDate().equals(day))
              .toList();
          VeterinarianSummaryResponse summary = toSummary(dailySlots, day);
          return new CalendarDaySummaryResponse(
              day,
              summary.totalSlots(),
              summary.availableSlots(),
              summary.bookedSlots(),
              summary.cancelledSlots(),
              !dailySlots.isEmpty()
          );
        })
        .toList();

    return new VeterinarianMonthSummaryResponse(month.toString(), days);
  }

  @Transactional
  public BulkSlotCreateResponse createBulkSlots(
      String authorizationHeader,
      BulkSlotCreateRequest request
  ) {
    VeterinaryContext context = requireApprovedVeterinarianContext(authorizationHeader);
    validateBulkRequest(request);
    OffsetDateTime now = now();

    LocalTime rangeStart = parseTime(request.startTime());
    LocalTime rangeEnd = parseTime(request.endTime());
    if (!rangeEnd.isAfter(rangeStart)) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "INVALID_SLOT_RANGE");
    }

    List<AppointmentSlot> createdSlots = new ArrayList<>();
    int skippedPastCount = 0;
    int conflictingCount = 0;
    int requestedCount = 0;
    LocalTime currentStart = rangeStart;
    while (currentStart.plusMinutes(request.slotDurationMinutes()).compareTo(rangeEnd) <= 0) {
      requestedCount++;
      OffsetDateTime slotStart = atOffset(request.date(), currentStart);
      OffsetDateTime slotEnd = slotStart.plusMinutes(request.slotDurationMinutes());

      if (!slotStart.isAfter(now)) {
        skippedPastCount++;
        currentStart = currentStart.plusMinutes(request.slotDurationMinutes());
        continue;
      }

      if (appointmentSlots.existsByVeterinarianIdAndStartTime(context.user().id, slotStart)) {
        conflictingCount++;
        currentStart = currentStart.plusMinutes(request.slotDurationMinutes());
        continue;
      }

      AppointmentSlot slot = new AppointmentSlot();
      slot.setVeterinarian(context.user());
      slot.setInstitution(context.institution());
      slot.setStartTime(slotStart);
      slot.setEndTime(slotEnd);
      slot.setStatus(AppointmentSlotStatus.AVAILABLE);
      slot.setNote(normalizeNote(request.note()));
      try {
        createdSlots.add(appointmentSlots.save(slot));
      } catch (DataIntegrityViolationException ex) {
        conflictingCount++;
      }
      currentStart = currentStart.plusMinutes(request.slotDurationMinutes());
    }

    if (createdSlots.isEmpty()) {
      if (skippedPastCount == requestedCount) {
        throw new ResponseStatusException(
            HttpStatus.BAD_REQUEST,
            "PAST_APPOINTMENT_SLOT_CREATION_NOT_ALLOWED"
        );
      }
      throw new ResponseStatusException(HttpStatus.CONFLICT, "APPOINTMENT_SLOT_CONFLICT");
    }

    return new BulkSlotCreateResponse(
        createdSlots.size(),
        skippedPastCount,
        conflictingCount,
        buildBulkCreateMessage(createdSlots.size(), skippedPastCount, conflictingCount),
        toInstitutionResponse(context.institution()),
        toSlotResponses(createdSlots, true)
    );
  }

  @Transactional
  public AppointmentSlotResponse cancelSlot(String authorizationHeader, long slotId) {
    VeterinaryContext context = requireApprovedVeterinarianContext(authorizationHeader);
    AppointmentSlot slot = appointmentSlots.findByIdForUpdate(slotId)
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "APPOINTMENT_SLOT_NOT_FOUND"));

    if (!slot.getVeterinarian().id.equals(context.user().id)) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "APPOINTMENT_SLOT_ACCESS_DENIED");
    }
    if (slot.getStatus() == AppointmentSlotStatus.BOOKED) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, "BOOKED_SLOT_CANCEL_NOT_SUPPORTED");
    }
    if (slot.getStatus() == AppointmentSlotStatus.CANCELLED) {
      return toSlotResponse(slot, true);
    }

    slot.setStatus(AppointmentSlotStatus.CANCELLED);
    slot.setCancelledAt(now());
    slot.setCancellationSource("VETERINARIAN");
    return toSlotResponse(appointmentSlots.save(slot), true);
  }

  public List<AppointmentSlotResponse> getAvailableSlots(long institutionId, LocalDate date) {
    return toSlotResponses(
        appointmentSlots.findAllByInstitutionIdAndStatusAndStartTimeBetweenOrderByStartTimeAsc(
                institutionId,
                AppointmentSlotStatus.AVAILABLE,
                startOfDay(date),
                startOfDay(date.plusDays(1))
            )
            .stream()
            .filter(slot -> slot.getStartTime().isAfter(now()))
            .toList(),
        false
    );
  }

  public AvailabilityStatusResponse getAvailabilityStatus(long institutionId) {
    boolean approvedVeterinarianConnected = claimRequests.existsByInstitutionIdAndStatus(
        institutionId,
        VeterinaryClaimStatus.APPROVED
    );
    long availableSlotCount = appointmentSlots.countByInstitutionIdAndStatus(
        institutionId,
        AppointmentSlotStatus.AVAILABLE
    );

    return new AvailabilityStatusResponse(
        institutionId,
        approvedVeterinarianConnected,
        availableSlotCount > 0
    );
  }

  @Transactional
  public AppointmentSlotResponse bookSlot(String authorizationHeader, long slotId) {
    User user = authContextService.requireStandardUser(authorizationHeader);
    AppointmentSlot slot = appointmentSlots.findByIdForUpdate(slotId)
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "APPOINTMENT_SLOT_NOT_FOUND"));

    if (!slot.getStartTime().isAfter(now())) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "PAST_APPOINTMENT_BOOKING_NOT_ALLOWED");
    }
    if (slot.getStatus() != AppointmentSlotStatus.AVAILABLE) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, "APPOINTMENT_SLOT_NOT_AVAILABLE");
    }

    slot.setStatus(AppointmentSlotStatus.BOOKED);
    slot.setBookedByUser(user);
    slot.setBookedByFirstName(normalizeName(user.firstName));
    slot.setBookedByLastName(normalizeName(user.lastName));
    slot.setBookedByEmail(user.email);

    try {
      return toSlotResponse(appointmentSlots.save(slot), false);
    } catch (DataIntegrityViolationException ex) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, "APPOINTMENT_SLOT_NOT_AVAILABLE");
    }
  }

  public List<AppointmentSlotResponse> getMyAppointments(String authorizationHeader) {
    User user = authContextService.requireStandardUser(authorizationHeader);
    return toSlotResponses(
        appointmentSlots.findAllByBookedByUserIdAndStatusAndStartTimeGreaterThanEqualOrderByStartTimeAsc(
            user.id,
            AppointmentSlotStatus.BOOKED,
            now()
        ),
        false
    );
  }

  @Transactional
  public AppointmentSlotResponse cancelBooking(String authorizationHeader, long slotId) {
    User user = authContextService.requireStandardUser(authorizationHeader);
    AppointmentSlot slot = appointmentSlots.findByIdForUpdate(slotId)
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "APPOINTMENT_SLOT_NOT_FOUND"));

    if (slot.getStatus() != AppointmentSlotStatus.BOOKED) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, "APPOINTMENT_SLOT_NOT_BOOKED");
    }
    if (slot.getBookedByUser() == null || !slot.getBookedByUser().id.equals(user.id)) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "APPOINTMENT_SLOT_BOOKING_ACCESS_DENIED");
    }

    slot.setStatus(AppointmentSlotStatus.AVAILABLE);
    slot.setBookedByUser(null);
    slot.setBookedByFirstName(null);
    slot.setBookedByLastName(null);
    slot.setBookedByEmail(null);

    return toSlotResponse(appointmentSlots.save(slot), false);
  }

  @Transactional
  public AppointmentSlotResponse cancelBookedSlot(
      String authorizationHeader,
      long slotId,
      CancelBookedSlotRequest request
  ) {
    VeterinaryContext context = requireApprovedVeterinarianContext(authorizationHeader);
    String reason = normalizeReason(request);
    OffsetDateTime now = now();

    AppointmentSlot slot = appointmentSlots.findByIdForUpdate(slotId)
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "APPOINTMENT_SLOT_NOT_FOUND"));

    if (!slot.getVeterinarian().id.equals(context.user().id)) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "APPOINTMENT_SLOT_ACCESS_DENIED");
    }
    if (slot.getStatus() != AppointmentSlotStatus.BOOKED) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, "APPOINTMENT_SLOT_NOT_BOOKED");
    }
    if (!slot.getStartTime().isAfter(now)) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "PAST_BOOKED_APPOINTMENT_CANNOT_BE_CANCELLED");
    }

    slot.setStatus(AppointmentSlotStatus.CANCELLED);
    slot.setCancellationReason(reason);
    slot.setCancelledAt(now);
    slot.setCancellationSource("VETERINARIAN");

    AppointmentSlot saved = appointmentSlots.save(slot);
    sendBookedCancellationEmail(saved, reason);
    return toSlotResponse(saved, true);
  }

  private VeterinaryContext requireApprovedVeterinarianContext(String authorizationHeader) {
    User veterinarian = authContextService.requireRole(authorizationHeader, Role.VETERINARIAN);
    VeterinaryClaimRequest claim = claimRequests
        .findTopByUserIdAndStatusOrderByCreatedAtDesc(veterinarian.id, VeterinaryClaimStatus.APPROVED)
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.FORBIDDEN, "VETERINARIAN_CLAIM_APPROVAL_REQUIRED"));

    return new VeterinaryContext(veterinarian, claim.getInstitution());
  }

  private void validateBulkRequest(BulkSlotCreateRequest request) {
    if (request == null || request.date() == null) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "DATE_REQUIRED");
    }
    if (request.startTime() == null || request.startTime().isBlank()
        || request.endTime() == null || request.endTime().isBlank()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "TIME_RANGE_REQUIRED");
    }
    if (!ALLOWED_SLOT_DURATIONS.contains(request.slotDurationMinutes())) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "INVALID_SLOT_DURATION");
    }
  }

  private String buildBulkCreateMessage(int createdCount, int skippedPastCount, int conflictingCount) {
    List<String> parts = new ArrayList<>();
    parts.add(createdCount + " slot olusturuldu.");
    if (skippedPastCount > 0) {
      parts.add(skippedPastCount + " gecmis zamanli slot atlandi.");
    }
    if (conflictingCount > 0) {
      parts.add(conflictingCount + " cakisan slot atlandi.");
    }
    return String.join(" ", parts);
  }

  private LocalTime parseTime(String value) {
    try {
      return LocalTime.parse(value, TIME_FORMATTER);
    } catch (Exception ex) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "INVALID_TIME_FORMAT");
    }
  }

  private OffsetDateTime startOfDay(LocalDate date) {
    return atOffset(date, LocalTime.MIDNIGHT);
  }

  private OffsetDateTime atOffset(LocalDate date, LocalTime time) {
    ZoneOffset offset = ZoneId.systemDefault().getRules().getOffset(OffsetDateTime.now().toInstant());
    return OffsetDateTime.of(date, time, offset);
  }

  private String normalizeNote(String note) {
    if (note == null) {
      return null;
    }
    String normalized = note.trim();
    return normalized.isEmpty() ? null : normalized;
  }

  private String normalizeName(String value) {
    if (value == null) {
      return null;
    }
    String normalized = value.trim();
    return normalized.isEmpty() ? null : normalized;
  }

  private String normalizeReason(CancelBookedSlotRequest request) {
    if (request == null || request.reason() == null || request.reason().trim().isEmpty()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "BOOKED_SLOT_CANCELLATION_REASON_REQUIRED");
    }
    return request.reason().trim();
  }

  private void sendBookedCancellationEmail(AppointmentSlot slot, String reason) {
    if (slot.getBookedByEmail() == null || slot.getBookedByEmail().isBlank()) {
      return;
    }
    emailService.sendVeterinarianCancelledAppointmentEmail(
        slot.getBookedByEmail().trim(),
        slot.getInstitution().getName(),
        DATE_FORMATTER.format(slot.getStartTime().toLocalDate()),
        TIME_FORMATTER.format(slot.getStartTime().toLocalTime()),
        reason
    );
  }

  private OffsetDateTime now() {
    return OffsetDateTime.now(ZoneId.systemDefault());
  }

  private List<AppointmentSlotResponse> toSlotResponses(List<AppointmentSlot> slots, boolean includeBookingContact) {
    return slots.stream()
        .map(slot -> toSlotResponse(slot, includeBookingContact))
        .toList();
  }

  private AppointmentSlotResponse toSlotResponse(AppointmentSlot slot, boolean includeBookingContact) {
    return new AppointmentSlotResponse(
        slot.getId(),
        slot.getInstitution().getId(),
        slot.getInstitution().getName(),
        slot.getStartTime(),
        slot.getEndTime(),
        slot.getStatus().name(),
        includeBookingContact && slot.getBookedByUser() != null ? slot.getBookedByUser().id : null,
        includeBookingContact ? slot.getBookedByFirstName() : null,
        includeBookingContact ? slot.getBookedByLastName() : null,
        includeBookingContact ? slot.getBookedByEmail() : null,
        slot.getNote(),
        slot.getCancellationReason(),
        slot.getCancelledAt(),
        slot.getCancellationSource(),
        slot.getCreatedAt(),
        slot.getUpdatedAt()
    );
  }

  private VeterinarianSummaryResponse toSummary(List<AppointmentSlot> slots, LocalDate date) {
    long availableCount = slots.stream()
        .filter(slot -> slot.getStatus() == AppointmentSlotStatus.AVAILABLE)
        .count();
    long bookedCount = slots.stream()
        .filter(slot -> slot.getStatus() == AppointmentSlotStatus.BOOKED)
        .count();
    long cancelledCount = slots.stream()
        .filter(slot -> slot.getStatus() == AppointmentSlotStatus.CANCELLED)
        .count();
    return new VeterinarianSummaryResponse(date, slots.size(), availableCount, bookedCount, cancelledCount);
  }

  private InstitutionCompactResponse toInstitutionResponse(Institution institution) {
    return new InstitutionCompactResponse(
        institution.getId(),
        institution.getName(),
        institution.getAddress(),
        institution.getEmail(),
        institution.getPhone(),
        institution.getWebsite(),
        institution.getDescription(),
        institution.getOpeningHours(),
        institution.getCity(),
        institution.getDistrict()
    );
  }

  private record VeterinaryContext(User user, Institution institution) {}

  public record BulkSlotCreateRequest(
      LocalDate date,
      String startTime,
      String endTime,
      Integer slotDurationMinutes,
      String note
  ) {}

  public record BulkSlotCreateResponse(
      int createdCount,
      int skippedPastCount,
      int conflictingCount,
      String message,
      InstitutionCompactResponse institution,
      List<AppointmentSlotResponse> slots
  ) {}

  public record CancelBookedSlotRequest(String reason) {}

  public record AppointmentSlotResponse(
      Long id,
      Long institutionId,
      String institutionName,
      OffsetDateTime startTime,
      OffsetDateTime endTime,
      String status,
      Long bookedByUserId,
      String bookedByFirstName,
      String bookedByLastName,
      String bookedByEmail,
      String note,
      String cancellationReason,
      OffsetDateTime cancelledAt,
      String cancellationSource,
      OffsetDateTime createdAt,
      OffsetDateTime updatedAt
  ) {}

  public record VeterinarianDaySlotsResponse(
      InstitutionCompactResponse institution,
      VeterinarianSummaryResponse summary,
      List<AppointmentSlotResponse> slots
  ) {}

  public record VeterinarianSummaryResponse(
      LocalDate date,
      long totalSlots,
      long availableSlots,
      long bookedSlots,
      long cancelledSlots
  ) {}

  public record VeterinarianMonthSummaryResponse(
      String month,
      List<CalendarDaySummaryResponse> days
  ) {}

  public record CalendarDaySummaryResponse(
      LocalDate date,
      long totalSlots,
      long availableSlots,
      long bookedSlots,
      long cancelledSlots,
      boolean hasSlots
  ) {}

  public record AvailabilityStatusResponse(
      long institutionId,
      boolean approvedVeterinarianConnected,
      boolean hasAvailableSlots
  ) {}

  public record InstitutionCompactResponse(
      Long id,
      String name,
      String address,
      String email,
      String phone,
      String website,
      String description,
      String openingHours,
      String city,
      String district
  ) {}
}
