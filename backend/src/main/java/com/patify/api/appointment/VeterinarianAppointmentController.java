package com.patify.api.appointment;

import java.time.LocalDate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

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
  public AppointmentSlotService.VeterinarianSummaryResponse getSummary(
      @RequestHeader("Authorization") String authorizationHeader,
      @RequestParam LocalDate date
  ) {
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
