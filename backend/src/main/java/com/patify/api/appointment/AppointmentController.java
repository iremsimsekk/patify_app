package com.patify.api.appointment;

import java.time.LocalDate;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/appointments")
public class AppointmentController {
  private final AppointmentSlotService appointmentSlotService;

  public AppointmentController(AppointmentSlotService appointmentSlotService) {
    this.appointmentSlotService = appointmentSlotService;
  }

  @GetMapping("/veterinarians/{institutionId}/available-slots")
  public List<AppointmentSlotService.AppointmentSlotResponse> getAvailableSlots(
      @PathVariable long institutionId,
      @RequestParam LocalDate date
  ) {
    return appointmentSlotService.getAvailableSlots(institutionId, date);
  }

  @PostMapping("/slots/{slotId}/book")
  public AppointmentSlotService.AppointmentSlotResponse bookSlot(
      @RequestHeader("Authorization") String authorizationHeader,
      @PathVariable long slotId
  ) {
    return appointmentSlotService.bookSlot(authorizationHeader, slotId);
  }
}
