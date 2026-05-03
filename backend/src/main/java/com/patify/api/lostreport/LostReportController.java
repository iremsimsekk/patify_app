package com.patify.api.lostreport;

import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/lost-reports")
public class LostReportController {
  private final LostReportService lostReportService;

  public LostReportController(LostReportService lostReportService) {
    this.lostReportService = lostReportService;
  }

  @PostMapping
  public LostReportService.LostReportResponse create(
      @RequestBody LostReportService.CreateLostReportRequest req
  ) {
    return lostReportService.create(req);
  }

  @GetMapping
  public List<LostReportService.LostReportResponse> listActive(
      @RequestParam(required = false) String email
  ) {
    return lostReportService.listActive(email);
  }

  @GetMapping("/{id}")
  public LostReportService.LostReportResponse getById(
      @PathVariable long id,
      @RequestParam(required = false) String email
  ) {
    return lostReportService.getById(id, email);
  }

  @PostMapping("/{id}/notify")
  public LostReportService.LostReportResponse notify(@PathVariable long id) {
    return lostReportService.markNotificationSent(id);
  }

  @PostMapping("/{id}/found")
  public LostReportService.LostReportResponse markFound(
      @PathVariable long id,
      @RequestParam String email
  ) {
    return lostReportService.markFound(id, email);
  }

  @GetMapping("/notifications")
  public List<LostReportService.NotificationResponse> notifications(
      @RequestParam String email,
      @RequestParam(defaultValue = "false") boolean unreadOnly
  ) {
    return lostReportService.listNotifications(email, unreadOnly);
  }

  @PostMapping("/notifications/{id}/read")
  public LostReportService.NotificationResponse markNotificationRead(
      @PathVariable long id,
      @RequestParam String email
  ) {
    return lostReportService.markNotificationRead(id, email);
  }
}
