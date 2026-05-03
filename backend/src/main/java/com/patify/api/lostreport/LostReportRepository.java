package com.patify.api.lostreport;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LostReportRepository extends JpaRepository<LostReport, Long> {
  List<LostReport> findAllByStatusOrderByCreatedAtDesc(String status);
}
