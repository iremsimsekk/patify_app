package com.patify.api.appointment;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import jakarta.persistence.LockModeType;

public interface AppointmentSlotRepository extends JpaRepository<AppointmentSlot, Long> {
  @EntityGraph(attributePaths = {"institution", "bookedByUser", "veterinarian"})
  List<AppointmentSlot> findAllByVeterinarianIdAndStartTimeBetweenOrderByStartTimeAsc(
      Long veterinarianId,
      OffsetDateTime startInclusive,
      OffsetDateTime endExclusive
  );

  @EntityGraph(attributePaths = {"institution", "bookedByUser", "veterinarian"})
  List<AppointmentSlot> findAllByInstitutionIdAndStatusAndStartTimeBetweenOrderByStartTimeAsc(
      Long institutionId,
      AppointmentSlotStatus status,
      OffsetDateTime startInclusive,
      OffsetDateTime endExclusive
  );

  boolean existsByVeterinarianIdAndStartTime(Long veterinarianId, OffsetDateTime startTime);

  @EntityGraph(attributePaths = {"institution", "bookedByUser", "veterinarian"})
  @Lock(LockModeType.PESSIMISTIC_WRITE)
  @Query("select s from AppointmentSlot s where s.id = :id")
  Optional<AppointmentSlot> findByIdForUpdate(@Param("id") Long id);

  @EntityGraph(attributePaths = {"institution", "bookedByUser", "veterinarian"})
  List<AppointmentSlot> findAllByBookedByUserIdAndStatusAndStartTimeGreaterThanEqualOrderByStartTimeAsc(
      Long bookedByUserId,
      AppointmentSlotStatus status,
      OffsetDateTime startInclusive
  );

  long countByInstitutionIdAndStatus(Long institutionId, AppointmentSlotStatus status);
}
