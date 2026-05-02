package com.patify.api.institution;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.IOException;
import java.time.OffsetDateTime;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class InstitutionService {
  private final InstitutionRepository institutions;
  private final ObjectMapper objectMapper;

  public InstitutionService(InstitutionRepository institutions, ObjectMapper objectMapper) {
    this.institutions = institutions;
    this.objectMapper = objectMapper;
  }

  public List<InstitutionSummaryResponse> listByType(String typeValue) {
    InstitutionType type;
    try {
      type = InstitutionType.fromDbValue(typeValue);
    } catch (IllegalArgumentException ex) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "INVALID_INSTITUTION_TYPE");
    }

    List<Institution> results = switch (type) {
      case CLINIC, VETERINARY -> institutions.findAllByTypeInAndDeletedAtIsNullOrderByNameAsc(
          List.of(InstitutionType.CLINIC.dbValue(), InstitutionType.VETERINARY.dbValue())
      );
      case SHELTER -> institutions.findAllByTypeAndDeletedAtIsNullOrderByNameAsc(type.dbValue());
    };

    return results.stream()
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
        institution.getInternationalPhoneNumber(),
        institution.getWebsite(),
        readOpeningHours(institution.getOpeningHours()),
        institution.getRating(),
        institution.getUserRatingCount(),
        institution.getGoogleMapsUrl(),
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
        institution.getInternationalPhoneNumber(),
        institution.getEmail(),
        institution.getWebsite(),
        institution.getAddress(),
        institution.getCity(),
        institution.getDistrict(),
        institution.getDescription(),
        readOpeningHours(institution.getOpeningHours()),
        institution.getRating(),
        institution.getUserRatingCount(),
        institution.getGoogleMapsUrl(),
        location != null ? location.getLatitude() : null,
        location != null ? location.getLongitude() : null,
        institution.getExternalSourceId(),
        institution.getCreatedAt(),
        institution.getUpdatedAt()
    );
  }

  private List<String> readOpeningHours(String openingHours) {
    if (openingHours == null || openingHours.isBlank()) {
      return null;
    }

    try {
      return objectMapper.readValue(openingHours, new TypeReference<List<String>>() {});
    } catch (IOException ex) {
      return List.of(openingHours);
    }
  }

  public record InstitutionSummaryResponse(
      Long id,
      String name,
      String address,
      String district,
      String phone,
      String internationalPhoneNumber,
      String website,
      List<String> openingHours,
      Double rating,
      Integer userRatingCount,
      String googleMapsUrl,
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
      String internationalPhoneNumber,
      String email,
      String website,
      String address,
      String city,
      String district,
      String description,
      List<String> openingHours,
      Double rating,
      Integer userRatingCount,
      String googleMapsUrl,
      Double latitude,
      Double longitude,
      String externalSourceId,
      OffsetDateTime createdAt,
      OffsetDateTime updatedAt
  ) {}
}
