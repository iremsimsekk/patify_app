package com.patify.api.institution;

import com.patify.api.institution.GooglePlacesImportClient.ExternalPlaceDetails;
import com.patify.api.institution.GooglePlacesImportClient.ExternalPlaceSummary;
import java.text.Normalizer;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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

  private final GooglePlacesImportClient googlePlacesImportClient;
  private final InstitutionRepository institutionRepository;

  public InstitutionImportService(
      GooglePlacesImportClient googlePlacesImportClient,
      InstitutionRepository institutionRepository
  ) {
    this.googlePlacesImportClient = googlePlacesImportClient;
    this.institutionRepository = institutionRepository;
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

    return new ImportResult(clinics.size(), shelters.size(), inserted, updated);
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
        clean(address),
        district,
        summary.latitude(),
        summary.longitude(),
        clean(summary.placeId())
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
    institution.setAddress(record.address());
    institution.setDistrict(record.district());
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

  private enum UpsertOutcome {
    INSERTED,
    UPDATED
  }

  private record NormalizedInstitution(
      InstitutionType type,
      String name,
      String phone,
      String address,
      String district,
      double latitude,
      double longitude,
      String externalSourceId
  ) {}

  public record ImportResult(
      int clinicsFetched,
      int sheltersFetched,
      int inserted,
      int updated
  ) {}
}
