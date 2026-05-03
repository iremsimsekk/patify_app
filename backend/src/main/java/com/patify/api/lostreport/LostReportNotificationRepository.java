package com.patify.api.lostreport;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LostReportNotificationRepository
    extends JpaRepository<LostReportNotification, Long> {
  int countByLostReportId(Long lostReportId);

  List<LostReportNotification> findAllByUserIdOrderByCreatedAtDesc(Long userId);
}
