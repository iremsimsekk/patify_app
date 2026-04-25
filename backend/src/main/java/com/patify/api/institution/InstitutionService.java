package com.patify.api.institution;

import java.time.OffsetDateTime;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class InstitutionService {
  private final InstitutionRepository institutions;

  public InstitutionService(InstitutionRepository institutions) {
    this.institutions = institutions;
  }

  public List<InstitutionSummaryResponse> listByType(String typeValue) {
    InstitutionType type;
    try {
      type = InstitutionType.fromDbValue(typeValue);
    } catch (IllegalArgumentException ex) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "INVALID_INSTITUTION_TYPE");
    }
    return institutions.findAllByTypeAndDeletedAtIsNullOrderByNameAsc(type.dbValue()).stream()
        .map(this::toSummary)
        .toList();
  }

  public InstitutionDetailResponse getById(long id) {
    Institution institution = institutions.findByIdAndDeletedAtIsNull(id)
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "INSTITUTION_NOT_FOUND"));
    return toDetail(institution);
  }

  private InstitutionSummaryResponse toSummary(Institution institution) {
    InstitutionType type = InstitutionType.fromDbValue(institution.getType());
    InstitutionLocation location = institution.getLocation();

    return new InstitutionSummaryResponse(
        institution.getId(),
        institution.getName(),
        institution.getAddress(),
        institution.getDistrict(),
        institution.getPhone(),
        location != null ? location.getLatitude() : null,
        location != null ? location.getLongitude() : null,
        institution.getExternalSourceId(),
        type.apiCategory(),
        institution.getCreatedAt(),
        institution.getUpdatedAt()
    );
  }

  private InstitutionDetailResponse toDetail(Institution institution) {
    InstitutionType type = InstitutionType.fromDbValue(institution.getType());
    InstitutionLocation location = institution.getLocation();

    return new InstitutionDetailResponse(
        institution.getId(),
        type.dbValue(),
        type.apiCategory(),
        institution.getName(),
        institution.getPhone(),
        institution.getAddress(),
        institution.getDistrict(),
        location != null ? location.getLatitude() : null,
        location != null ? location.getLongitude() : null,
        institution.getExternalSourceId(),
        institution.getCreatedAt(),
        institution.getUpdatedAt()
    );
  }

  public record InstitutionSummaryResponse(
      Long id,
      String name,
      String address,
      String district,
      String phone,
      Double latitude,
      Double longitude,
      String externalSourceId,
      String category,
      OffsetDateTime createdAt,
      OffsetDateTime updatedAt
  ) {}

  public record InstitutionDetailResponse(
      Long id,
      String type,
      String category,
      String name,
      String phone,
      String address,
      String district,
      Double latitude,
      Double longitude,
      String externalSourceId,
      OffsetDateTime createdAt,
      OffsetDateTime updatedAt
  ) {}
}
