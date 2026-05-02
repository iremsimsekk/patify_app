package com.patify.api.veterinarian;

import java.util.Optional;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VeterinaryClaimRequestRepository
    extends JpaRepository<VeterinaryClaimRequest, Long> {
  @EntityGraph(attributePaths = {"institution", "institution.location"})
  Optional<VeterinaryClaimRequest> findTopByUserIdOrderByCreatedAtDesc(Long userId);

  @EntityGraph(attributePaths = {"institution", "institution.location"})
  Optional<VeterinaryClaimRequest> findTopByUserIdAndInstitutionIdAndStatusOrderByCreatedAtDesc(
      Long userId,
      Long institutionId,
      VeterinaryClaimStatus status
  );

  @EntityGraph(attributePaths = {"institution", "institution.location", "user"})
  Optional<VeterinaryClaimRequest> findById(Long id);
}
