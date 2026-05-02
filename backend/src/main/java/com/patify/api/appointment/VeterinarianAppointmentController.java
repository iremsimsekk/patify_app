package com.patify.api.appointment;

import java.time.LocalDate;
import java.time.YearMonth;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/veterinarian/appointments")
public class VeterinarianAppointmentController {
  private final AppointmentSlotService appointmentSlotService;

  public VeterinarianAppointmentController(AppointmentSlotService appointmentSlotService) {
    this.appointmentSlotService = appointmentSlotService;
  }

  @GetMapping("/slots")
  public AppointmentSlotService.VeterinarianDaySlotsResponse getSlots(
      @RequestHeader("Authorization") String authorizationHeader,
      @RequestParam LocalDate date
  ) {
    return appointmentSlotService.getVeterinarianSlots(authorizationHeader, date);
  }

  @GetMapping("/summary")
  public Object getSummary(
      @RequestHeader("Authorization") String authorizationHeader,
      @RequestParam(required = false) LocalDate date,
      @RequestParam(required = false) String month
  ) {
    if (month != null && !month.isBlank()) {
      return appointmentSlotService.getVeterinarianMonthSummary(
          authorizationHeader,
          YearMonth.parse(month.trim())
      );
    }
    if (date == null) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "DATE_OR_MONTH_REQUIRED");
    }
    return appointmentSlotService.getVeterinarianSummary(authorizationHeader, date);
  }

  @PostMapping("/slots/bulk")
  public AppointmentSlotService.BulkSlotCreateResponse createBulkSlots(
      @RequestHeader("Authorization") String authorizationHeader,
      @RequestBody AppointmentSlotService.BulkSlotCreateRequest request
  ) {
    return appointmentSlotService.createBulkSlots(authorizationHeader, request);
  }

  @PatchMapping("/slots/{id}/cancel")
  public AppointmentSlotService.AppointmentSlotResponse cancelSlot(
      @RequestHeader("Authorization") String authorizationHeader,
      @PathVariable long id
  ) {
    return appointmentSlotService.cancelSlot(authorizationHeader, id);
  }
}
