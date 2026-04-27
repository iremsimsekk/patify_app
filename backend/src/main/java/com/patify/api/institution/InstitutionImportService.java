package com.patify.api.institution;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.patify.api.institution.GooglePlacesImportClient.ExternalPlaceDetails;
import com.patify.api.institution.GooglePlacesImportClient.ExternalPlaceSummary;
import java.io.IOException;
import java.io.InputStream;
import java.text.Normalizer;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class InstitutionImportService {
  private static final Logger log = LoggerFactory.getLogger(InstitutionImportService.class);
  private static final List<String> KNOWN_DISTRICTS = List.of(
      "altindag", "akyurt", "ayas", "bala", "beypazari", "camlidere",
      "cankaya", "cubuk", "elmadag", "etimesgut", "evren", "golbasi",
      "gudul", "haymana", "kahramankazan", "kalecik", "kecioren",
      "kizilcahamam", "mamak", "nallihan", "polatli", "pursaklar",
      "sereflikochisar", "sincan", "yenimahalle"
  );
  private static final List<String> SHELTER_INCLUDE_KEYWORDS = List.of(
      "barin", "bakimevi", "rehabilitasyon", "sokak hayvan", "sahipsiz hayvan", "kurtarma", "koruma"
  );
  private static final List<String> SHELTER_EXCLUDE_KEYWORDS = List.of(
      "otel", "hotel", "pet shop", "petshop", "magaza", "dukkan", "park", "restoran",
      "restaurant", "ciftlik", "farm", "belediyesi", "belediye", "mudurlugu"
  );

  private final GooglePlacesImportClient googlePlacesImportClient;
  private final InstitutionRepository institutionRepository;
  private final ObjectMapper objectMapper;
  private final ResourceLoader resourceLoader;

  public InstitutionImportService(
      GooglePlacesImportClient googlePlacesImportClient,
      InstitutionRepository institutionRepository,
      ObjectMapper objectMapper,
      ResourceLoader resourceLoader
  ) {
    this.googlePlacesImportClient = googlePlacesImportClient;
    this.institutionRepository = institutionRepository;
    this.objectMapper = objectMapper;
    this.resourceLoader = resourceLoader;
  }

  @Transactional
  public ImportResult importInstitutions() {
    log.info("Starting institution import using existing Google Places integration for Ankara.");

    List<NormalizedInstitution> clinics = normalizeAll(googlePlacesImportClient.fetchAnkaraVets());
    List<NormalizedInstitution> shelters = normalizeAll(googlePlacesImportClient.fetchAnkaraShelters());

    int inserted = 0;
    int updated = 0;
    for (NormalizedInstitution record : combine(clinics, shelters)) {
      UpsertOutcome outcome = upsert(record);
      if (outcome == UpsertOutcome.INSERTED) {
        inserted++;
      } else {
        updated++;
      }
    }

    log.info(
        "Institution import finished successfully. clinics={}, shelters={}, inserted={}, updated={}",
        clinics.size(),
        shelters.size(),
        inserted,
        updated
    );

    return new ImportResult(clinics.size(), shelters.size(), 0, inserted, updated);
  }

  @Transactional
  public ImportResult importInstitutionsFromJson(String clinicsResourceLocation, String sheltersResourceLocation) {
    log.info(
        "Starting institution import from local JSON files. clinicsResource={} sheltersResource={}",
        clinicsResourceLocation,
        sheltersResourceLocation
    );

    List<NormalizedInstitution> clinics = normalizeJsonRecords(loadJsonRecords(clinicsResourceLocation), InstitutionType.CLINIC);
    ShelterNormalizationResult shelterResult =
        normalizeShelterJsonRecords(loadJsonRecords(sheltersResourceLocation));

    int inserted = 0;
    int updated = 0;
    for (NormalizedInstitution record : combine(clinics, shelterResult.acceptedRecords())) {
      UpsertOutcome outcome = upsert(record);
      if (outcome == UpsertOutcome.INSERTED) {
        inserted++;
      } else {
        updated++;
      }
    }

    log.info(
        "Institution JSON import finished successfully. clinics={}, shelters={}, shelterSkipped={}, inserted={}, updated={}",
        clinics.size(),
        shelterResult.acceptedRecords().size(),
        shelterResult.skippedCount(),
        inserted,
        updated
    );

    return new ImportResult(
        clinics.size(),
        shelterResult.acceptedRecords().size(),
        shelterResult.skippedCount(),
        inserted,
        updated
    );
  }

  private List<NormalizedInstitution> normalizeAll(List<ExternalPlaceSummary> summaries) {
    List<NormalizedInstitution> out = new ArrayList<>();
    for (ExternalPlaceSummary summary : summaries) {
      out.add(normalize(summary));
    }
    return out;
  }

  private NormalizedInstitution normalize(ExternalPlaceSummary summary) {
    ExternalPlaceDetails details = fetchDetailsSafely(summary.placeId());
    String name = firstNonBlank(details != null ? details.name() : null, summary.name());
    String address = firstNonBlank(details != null ? details.formattedAddress() : null, summary.address());
    String phone = details != null ? clean(details.phone()) : null;
    String district = extractDistrict(address);

    return new NormalizedInstitution(
        summary.type(),
        clean(name),
        phone,
        null,
        clean(address),
        district,
        null,
        null,
        null,
        null,
        summary.latitude(),
        summary.longitude(),
        null,
        clean(summary.placeId())
    );
  }

  private List<NormalizedInstitution> normalizeJsonRecords(
      List<LegacyGoogleInstitutionRecord> records,
      InstitutionType forcedType
  ) {
    List<NormalizedInstitution> out = new ArrayList<>();
    for (LegacyGoogleInstitutionRecord record : records) {
      out.add(normalizeJsonRecord(record, forcedType));
    }
    return out;
  }

  private ShelterNormalizationResult normalizeShelterJsonRecords(List<LegacyGoogleInstitutionRecord> records) {
    List<NormalizedInstitution> accepted = new ArrayList<>();
    int skipped = 0;

    for (LegacyGoogleInstitutionRecord record : records) {
      if (shouldSkipShelterRecord(record)) {
        skipped++;
        log.warn(
            "Skipping noisy shelter record externalSourceId={} name={} types={}",
            clean(record.externalSourceId()),
            clean(record.name()),
            record.types()
        );
        continue;
      }
      accepted.add(normalizeJsonRecord(record, InstitutionType.SHELTER));
    }

    return new ShelterNormalizationResult(accepted, skipped);
  }

  private NormalizedInstitution normalizeJsonRecord(
      LegacyGoogleInstitutionRecord record,
      InstitutionType forcedType
  ) {
    String name = clean(record.name());
    String address = clean(record.address());
    String district = firstNonBlank(clean(record.district()), extractDistrict(address));

    return new NormalizedInstitution(
        forcedType,
        name,
        clean(record.phone()),
        clean(record.internationalPhoneNumber()),
        address,
        district,
        clean(record.website()),
        serializeOpeningHours(record.openingHours()),
        record.rating(),
        record.userRatingCount(),
        record.latitude(),
        record.longitude(),
        clean(record.googleMapsUrl()),
        clean(record.externalSourceId())
    );
  }

  private ExternalPlaceDetails fetchDetailsSafely(String placeId) {
    try {
      return googlePlacesImportClient.fetchDetails(placeId);
    } catch (InstitutionImportException ex) {
      log.warn(
          "Detail enrichment skipped for placeId={} because {}: {}",
          placeId,
          ex.getCode(),
          ex.getMessage()
      );
      return null;
    }
  }

  private UpsertOutcome upsert(NormalizedInstitution record) {
    Institution institution = findExisting(record);
    UpsertOutcome outcome = institution == null ? UpsertOutcome.INSERTED : UpsertOutcome.UPDATED;

    if (institution == null) {
      institution = new Institution();
      institution.setType(record.type().dbValue());
    }

    institution.setName(record.name());
    institution.setPhone(record.phone());
    institution.setInternationalPhoneNumber(record.internationalPhoneNumber());
    institution.setAddress(record.address());
    institution.setDistrict(record.district());
    institution.setWebsite(record.website());
    institution.setOpeningHours(record.openingHours());
    institution.setRating(record.rating());
    institution.setUserRatingCount(record.userRatingCount());
    institution.setGoogleMapsUrl(record.googleMapsUrl());
    institution.setExternalSourceId(record.externalSourceId());

    Institution saved = institutionRepository.save(institution);

    InstitutionLocation location = saved.getLocation();
    if (location == null) {
      location = new InstitutionLocation();
      location.setInstitution(saved);
      saved.setLocation(location);
    }
    location.setLatitude(record.latitude());
    location.setLongitude(record.longitude());

    institutionRepository.save(saved);
    return outcome;
  }

  private Institution findExisting(NormalizedInstitution record) {
    if (record.externalSourceId() != null && !record.externalSourceId().isBlank()) {
      Institution existing = institutionRepository.findByExternalSourceId(record.externalSourceId()).orElse(null);
      if (existing != null) {
        return existing;
      }
    }
    return institutionRepository.findDuplicateCandidate(
        record.type().dbValue(),
        record.name(),
        record.address()
    ).orElse(null);
  }

  private static List<NormalizedInstitution> combine(
      List<NormalizedInstitution> clinics,
      List<NormalizedInstitution> shelters
  ) {
    List<NormalizedInstitution> out = new ArrayList<>(clinics.size() + shelters.size());
    out.addAll(clinics);
    out.addAll(shelters);
    return out;
  }

  private static String extractDistrict(String address) {
    String normalized = normalizeForCompare(address);
    if (normalized == null) {
      return null;
    }

    for (String district : KNOWN_DISTRICTS) {
      if (normalized.contains(district)) {
        return prettyDistrict(district);
      }
    }
    return null;
  }

  private static String prettyDistrict(String district) {
    return switch (district) {
      case "cankaya" -> "Cankaya";
      case "kecioren" -> "Kecioren";
      case "golbasi" -> "Golbasi";
      case "cubuk" -> "Cubuk";
      case "gudul" -> "Gudul";
      case "kizilcahamam" -> "Kizilcahamam";
      case "sereflikochisar" -> "Sereflikochisar";
      default -> district.substring(0, 1).toUpperCase(Locale.ROOT) + district.substring(1);
    };
  }

  private static String normalizeForCompare(String value) {
    String cleaned = clean(value);
    if (cleaned == null) {
      return null;
    }
    String ascii = Normalizer.normalize(cleaned, Normalizer.Form.NFD)
        .replaceAll("\\p{M}", "")
        .replace("ı", "i")
        .replace("İ", "i");
    return ascii.toLowerCase(Locale.ROOT);
  }

  private static String clean(String value) {
    if (value == null) {
      return null;
    }
    String trimmed = value.trim();
    return trimmed.isEmpty() ? null : trimmed;
  }

  private static String firstNonBlank(String first, String second) {
    String a = clean(first);
    if (a != null) {
      return a;
    }
    return clean(second);
  }

  private String serializeOpeningHours(List<String> openingHours) {
    if (openingHours == null || openingHours.isEmpty()) {
      return null;
    }

    try {
      return objectMapper.writeValueAsString(openingHours);
    } catch (IOException ex) {
      throw new InstitutionImportException(
          "IMPORT_OPENING_HOURS_SERIALIZE_ERROR",
          "Opening hours could not be serialized for import.",
          ex.getMessage()
      );
    }
  }

  private List<LegacyGoogleInstitutionRecord> loadJsonRecords(String resourceLocation) {
    Resource resource = resourceLoader.getResource(resourceLocation);
    if (!resource.exists()) {
      throw new InstitutionImportException(
          "IMPORT_JSON_NOT_FOUND",
          "JSON import file was not found: " + resourceLocation,
          resourceLocation
      );
    }

    try (InputStream inputStream = resource.getInputStream()) {
      return objectMapper.readValue(inputStream, new TypeReference<List<LegacyGoogleInstitutionRecord>>() {});
    } catch (IOException ex) {
      throw new InstitutionImportException(
          "IMPORT_JSON_READ_ERROR",
          "JSON import file could not be read: " + resourceLocation,
          ex.getMessage()
      );
    }
  }

  private boolean shouldSkipShelterRecord(LegacyGoogleInstitutionRecord record) {
    String normalizedName = normalizeForCompare(record.name());
    if (normalizedName == null) {
      return true;
    }

    for (String includeKeyword : SHELTER_INCLUDE_KEYWORDS) {
      if (normalizedName.contains(includeKeyword)) {
        return false;
      }
    }

    List<String> types = record.types() == null ? List.of() : record.types();
    for (String typeValue : types) {
      String normalizedType = normalizeForCompare(typeValue);
      if (normalizedType != null && normalizedType.contains("animal_shelter")) {
        return false;
      }
    }

    for (String excludeKeyword : SHELTER_EXCLUDE_KEYWORDS) {
      if (normalizedName.contains(excludeKeyword)) {
        return true;
      }
    }

    return false;
  }

  private enum UpsertOutcome {
    INSERTED,
    UPDATED
  }

  private record ShelterNormalizationResult(
      List<NormalizedInstitution> acceptedRecords,
      int skippedCount
  ) {}

  private record NormalizedInstitution(
      InstitutionType type,
      String name,
      String phone,
      String internationalPhoneNumber,
      String address,
      String district,
      String website,
      String openingHours,
      Double rating,
      Integer userRatingCount,
      double latitude,
      double longitude,
      String googleMapsUrl,
      String externalSourceId
  ) {}

  @JsonIgnoreProperties(ignoreUnknown = true)
  private record LegacyGoogleInstitutionRecord(
      @JsonProperty("external_source_id")
      String externalSourceId,
      String type,
      String name,
      String address,
      String district,
      String phone,
      @JsonProperty("international_phone_number")
      String internationalPhoneNumber,
      String website,
      @JsonProperty("opening_hours")
      List<String> openingHours,
      Double rating,
      @JsonProperty("user_rating_count")
      Integer userRatingCount,
      double latitude,
      double longitude,
      @JsonProperty("google_maps_url")
      String googleMapsUrl,
      List<String> types
  ) {}

  public record ImportResult(
      int clinicsImported,
      int sheltersImported,
      int shelterRecordsSkipped,
      int inserted,
      int updated
  ) {}
}
