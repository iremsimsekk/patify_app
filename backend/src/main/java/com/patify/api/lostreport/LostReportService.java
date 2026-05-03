package com.patify.api.lostreport;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.patify.api.auth.User;
import com.patify.api.auth.UserRepository;
import java.util.List;
import java.time.OffsetDateTime;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class LostReportService {
  private final LostReportRepository lostReports;
  private final LostReportNotificationRepository notifications;
  private final UserRepository users;

  public LostReportService(
      LostReportRepository lostReports,
      LostReportNotificationRepository notifications,
      UserRepository users
  ) {
    this.lostReports = lostReports;
    this.notifications = notifications;
    this.users = users;
  }

  @Transactional
  public LostReportResponse create(CreateLostReportRequest req) {
    LostReport report = new LostReport();
    report.setUserId(resolveUserId(req));
    report.setPetType(required(req.petType(), "PET_TYPE_REQUIRED"));
    report.setDescription(required(req.description(), "DESCRIPTION_REQUIRED"));
    report.setImageUrl(blankToNull(req.imageUrl()));
    report.setLatitude(required(req.latitude(), "LATITUDE_REQUIRED"));
    report.setLongitude(required(req.longitude(), "LONGITUDE_REQUIRED"));
    report.setSeenAt(required(req.seenAt(), "SEEN_AT_REQUIRED"));
    report.setContactInfo(required(req.contactInfo(), "CONTACT_INFO_REQUIRED"));
    report.setDistrict(blankToNull(req.district()));
    report.setAddress(blankToNull(req.address()));
    report.setStatus("ACTIVE");
    report.setApproved(true);
    report.setNotificationSent(false);

    LostReport savedReport = lostReports.save(report);
    int recipientCount = sendInAppNotifications(savedReport);
    savedReport.setNotificationSent(true);

    return toResponse(
        lostReports.save(savedReport),
        "Lost report created and notifications sent",
        recipientCount
    );
  }

  @Transactional
  public LostReportResponse markNotificationSent(long id) {
    LostReport report = lostReports.findById(id).orElseThrow(
        () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "LOST_REPORT_NOT_FOUND")
    );

    if (report.isNotificationSent()) {
      return toResponse(
          report,
          "Notification already sent",
          notifications.countByLostReportId(report.getId())
      );
    }

    if (!isNotificationEligible(report)) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "LOST_REPORT_NOT_ELIGIBLE");
    }

    int recipientCount = sendInAppNotifications(report);
    report.setNotificationSent(true);
    return toResponse(
        lostReports.save(report),
        "Notification marked as sent",
        recipientCount
    );
  }

  @Transactional(readOnly = true)
  public LostReportResponse getById(long id, String email) {
    LostReport report = findReport(id);
    return toResponse(
        report,
        "Lost report loaded",
        notifications.countByLostReportId(report.getId()),
        canManage(report, email)
    );
  }

  @Transactional(readOnly = true)
  public List<LostReportResponse> listActive(String email) {
    return lostReports.findAllByStatusOrderByCreatedAtDesc("ACTIVE")
        .stream()
        .map(report -> toResponse(
            report,
            "Lost report loaded",
            notifications.countByLostReportId(report.getId()),
            canManage(report, email)
        ))
        .toList();
  }

  @Transactional
  public LostReportResponse markFound(long id, String email) {
    LostReport report = findReport(id);
    if (!canManage(report, email)) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "ONLY_OWNER_CAN_MARK_FOUND");
    }

    report.setStatus("FOUND");
    return toResponse(
        lostReports.save(report),
        "Lost report marked as found",
        notifications.countByLostReportId(report.getId()),
        true
    );
  }

  @Transactional(readOnly = true)
  public List<NotificationResponse> listNotifications(String email, boolean unreadOnly) {
    User user = users.findByEmail(required(email, "EMAIL_REQUIRED").toLowerCase()).orElseThrow(
        () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "USER_NOT_FOUND")
    );

    return notifications.findAllByUserIdOrderByCreatedAtDesc(user.id)
        .stream()
        .filter(notification -> !unreadOnly || notification.getReadAt() == null)
        .filter(notification -> lostReports.findById(notification.getLostReportId())
            .map(report -> "ACTIVE".equals(report.getStatus()))
            .orElse(false))
        .map(notification -> new NotificationResponse(
            notification.getId(),
            notification.getLostReportId(),
            notification.getTitle(),
            notification.getMessage(),
            notification.getReadAt() != null,
            notification.getCreatedAt()
        ))
        .toList();
  }

  @Transactional
  public NotificationResponse markNotificationRead(long id, String email) {
    User user = users.findByEmail(required(email, "EMAIL_REQUIRED").toLowerCase()).orElseThrow(
        () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "USER_NOT_FOUND")
    );
    LostReportNotification notification = notifications.findById(id).orElseThrow(
        () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "NOTIFICATION_NOT_FOUND")
    );

    if (!notification.getUserId().equals(user.id)) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "NOTIFICATION_OWNER_REQUIRED");
    }

    if (notification.getReadAt() == null) {
      notification.setReadAt(OffsetDateTime.now());
      notifications.save(notification);
    }

    return new NotificationResponse(
        notification.getId(),
        notification.getLostReportId(),
        notification.getTitle(),
        notification.getMessage(),
        true,
        notification.getCreatedAt()
    );
  }

  private Long resolveUserId(CreateLostReportRequest req) {
    if (req.userId() != null) {
      return req.userId();
    }

    String email = required(req.userEmail(), "USER_ID_OR_EMAIL_REQUIRED").toLowerCase();
    User user = users.findByEmail(email).orElseThrow(
        () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "USER_NOT_FOUND")
    );
    return user.id;
  }

  private LostReport findReport(long id) {
    return lostReports.findById(id).orElseThrow(
        () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "LOST_REPORT_NOT_FOUND")
    );
  }

  private boolean canManage(LostReport report, String email) {
    if (email == null || email.trim().isEmpty()) {
      return false;
    }

    return users.findByEmail(email.trim().toLowerCase())
        .map(user -> user.id.equals(report.getUserId()))
        .orElse(false);
  }

  private int sendInAppNotifications(LostReport report) {
    if (notifications.countByLostReportId(report.getId()) > 0) {
      return notifications.countByLostReportId(report.getId());
    }

    List<User> recipients = notificationRecipients(report);
    List<LostReportNotification> createdNotifications = recipients
        .stream()
        .map(user -> buildNotification(report, user))
        .toList();

    notifications.saveAll(createdNotifications);
    return createdNotifications.size();
  }

  private List<User> notificationRecipients(LostReport report) {
    String district = report.getDistrict();
    if (district != null && !district.isBlank()) {
      List<User> sameDistrictUsers =
          users.findAllByEmailVerifiedTrueAndDistrictIgnoreCase(district.trim());
      if (!sameDistrictUsers.isEmpty()) {
        return sameDistrictUsers;
      }
    }

    return users.findAllByEmailVerifiedTrue();
  }

  private LostReportNotification buildNotification(LostReport report, User user) {
    LostReportNotification notification = new LostReportNotification();
    notification.setLostReportId(report.getId());
    notification.setUserId(user.id);
    notification.setTitle("Kayıp hayvan ilanı");
    String districtText = report.getDistrict() == null ? "Ankara" : report.getDistrict();
    notification.setMessage(
        districtText + " bölgesinde " + report.getPetType() + " için yeni kayıp ilanı yayınlandı."
    );
    return notification;
  }

  private boolean isNotificationEligible(LostReport report) {
    return report.isApproved()
        && "ACTIVE".equals(report.getStatus())
        && !report.isNotificationSent();
  }

  private LostReportResponse toResponse(LostReport report, String message) {
    return toResponse(
        report,
        message,
        notifications.countByLostReportId(report.getId()),
        false
    );
  }

  private LostReportResponse toResponse(
      LostReport report,
      String message,
      int notificationRecipientCount
  ) {
    return toResponse(report, message, notificationRecipientCount, false);
  }

  private LostReportResponse toResponse(
      LostReport report,
      String message,
      int notificationRecipientCount,
      boolean canMarkFound
  ) {
    return new LostReportResponse(
        report.getId(),
        report.getUserId(),
        report.getPetType(),
        report.getDescription(),
        report.getImageUrl(),
        report.getLatitude(),
        report.getLongitude(),
        report.getSeenAt(),
        report.getContactInfo(),
        report.getDistrict(),
        report.getAddress(),
        report.getStatus(),
        report.isNotificationSent(),
        report.isApproved(),
        isNotificationEligible(report),
        notificationRecipientCount,
        canMarkFound,
        report.getCreatedAt(),
        message
    );
  }

  private String required(String value, String message) {
    if (value == null || value.trim().isEmpty()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, message);
    }
    return value.trim();
  }

  private <T> T required(T value, String message) {
    if (value == null) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, message);
    }
    return value;
  }

  private String blankToNull(String value) {
    return value == null || value.trim().isEmpty() ? null : value.trim();
  }

  public record CreateLostReportRequest(
      Long userId,
      String userEmail,
      String petType,
      String description,
      String imageUrl,
      Double latitude,
      Double longitude,
      OffsetDateTime seenAt,
      String contactInfo,
      String district,
      String address
  ) {}

  public record LostReportResponse(
      Long id,
      Long userId,
      String petType,
      String description,
      String imageUrl,
      Double latitude,
      Double longitude,
      OffsetDateTime seenAt,
      String contactInfo,
      String district,
      String address,
      String status,
      boolean notificationSent,
      @JsonProperty("isApproved")
      boolean isApproved,
      boolean notificationEligible,
      int notificationRecipientCount,
      boolean canMarkFound,
      OffsetDateTime createdAt,
      String message
  ) {}

  public record NotificationResponse(
      Long id,
      Long lostReportId,
      String title,
      String message,
      boolean read,
      OffsetDateTime createdAt
  ) {}
}
