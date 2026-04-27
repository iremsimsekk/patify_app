package com.patify.api.institution;

import com.fasterxml.jackson.databind.JsonNode;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatusCode;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.util.UriComponentsBuilder;

@Component
public class GooglePlacesImportClient {
  private static final Logger log = LoggerFactory.getLogger(GooglePlacesImportClient.class);
  private static final String FALLBACK_FRONTEND_GOOGLE_MAPS_KEY = "PATIFY_GOOGLE_MAPS_API_KEY";
  private static final double ANKARA_LAT = 39.92077;
  private static final double ANKARA_LNG = 32.85411;
  private static final int DEFAULT_RADIUS_METERS = 35000;
  private static final List<String> ANKARA_DISTRICTS = List.of(
      "cankaya", "yenimahalle", "kecioren", "mamak", "etimesgut", "sincan",
      "golbasi", "altindag", "pursaklar", "akyurt", "cubuk", "kahramankazan",
      "elmadag", "bala", "haymana", "polatli", "beypazari", "nallihan", "ayas",
      "gudul", "kalecik", "kizilcahamam", "camlidere", "evren", "sereflikochisar"
  );

  private final WebClient webClient;
  private final String apiKey;

  public GooglePlacesImportClient(
      WebClient.Builder webClientBuilder,
      @Value("${places.api.key:}") String configuredApiKey
  ) {
    this.webClient = webClientBuilder.build();
    this.apiKey = configuredApiKey == null || configuredApiKey.isBlank()
        ? FALLBACK_FRONTEND_GOOGLE_MAPS_KEY
        : configuredApiKey.trim();
  }

  public List<ExternalPlaceSummary> fetchAnkaraVets() {
    List<String> queries = new ArrayList<>();
    queries.add("veteriner ankara");
    queries.add("veterinary clinic ankara");
    for (String district : ANKARA_DISTRICTS) {
      queries.add("veteriner " + district + " ankara");
    }
    for (String district : ANKARA_DISTRICTS) {
      queries.add("veterinary clinic " + district + " ankara");
    }
    return fetchAcrossQueries(queries, InstitutionType.CLINIC);
  }

  public List<ExternalPlaceSummary> fetchAnkaraShelters() {
    List<String> queries = new ArrayList<>();
    queries.add("hayvan barinagi ankara");
    queries.add("animal shelter ankara");
    for (String district : ANKARA_DISTRICTS) {
      queries.add("hayvan barinagi " + district + " ankara");
    }
    for (String district : ANKARA_DISTRICTS) {
      queries.add("animal shelter " + district + " ankara");
    }
    return fetchAcrossQueries(queries, InstitutionType.SHELTER);
  }

  public ExternalPlaceDetails fetchDetails(String placeId) {
    JsonNode json = performRequest(
        "Place Details",
        "https://maps.googleapis.com/maps/api/place/details/json",
        builder -> builder
            .queryParam("place_id", placeId)
            .queryParam("fields", "place_id,name,formatted_address,formatted_phone_number")
            .queryParam("language", "tr")
            .queryParam("region", "tr")
            .queryParam("key", apiKey)
            .build()
            .toUri()
    );
    JsonNode result = json.path("result");
    return new ExternalPlaceDetails(
        textValue(result, "place_id"),
        textValue(result, "name"),
        textValue(result, "formatted_address"),
        textValue(result, "formatted_phone_number")
    );
  }

  private List<ExternalPlaceSummary> fetchAcrossQueries(List<String> queries, InstitutionType type) {
    Map<String, ExternalPlaceSummary> merged = new LinkedHashMap<>();

    for (String query : queries) {
      List<ExternalPlaceSummary> results = singlePageTextSearch(query, type);
      for (ExternalPlaceSummary place : results) {
        if (place.placeId() != null && !place.placeId().isBlank()) {
          merged.put(place.placeId(), place);
        }
      }
    }

    List<ExternalPlaceSummary> out = new ArrayList<>(merged.values());
    out.sort((left, right) -> left.name().compareToIgnoreCase(right.name()));
    log.info("Google import fetch completed for {} with {} unique rows.", type.dbValue(), out.size());
    return out;
  }

  private List<ExternalPlaceSummary> singlePageTextSearch(String query, InstitutionType type) {
    JsonNode json = performRequest(
        "TextSearch",
        "https://maps.googleapis.com/maps/api/place/textsearch/json",
        builder -> builder
            .queryParam("query", query)
            .queryParam("location", ANKARA_LAT + "," + ANKARA_LNG)
            .queryParam("radius", DEFAULT_RADIUS_METERS)
            .queryParam("language", "tr")
            .queryParam("region", "tr")
            .queryParam("key", apiKey)
            .build()
            .toUri()
    );

    List<ExternalPlaceSummary> results = new ArrayList<>();
    JsonNode rows = json.path("results");
    if (!rows.isArray()) {
      return results;
    }

    for (JsonNode row : rows) {
      JsonNode location = row.path("geometry").path("location");
      String placeId = textValue(row, "place_id");
      if (placeId == null || placeId.isBlank()) {
        continue;
      }

      results.add(new ExternalPlaceSummary(
          placeId,
          textValue(row, "name"),
          location.path("lat").asDouble(),
          location.path("lng").asDouble(),
          firstNonBlank(textValue(row, "formatted_address"), textValue(row, "vicinity")),
          type
      ));
    }
    return results;
  }

  private JsonNode performRequest(
      String requestLabel,
      String url,
      java.util.function.Function<UriComponentsBuilder, java.net.URI> uriCustomizer
  ) {
    String body = webClient.get()
        .uri(uriCustomizer.apply(UriComponentsBuilder.fromHttpUrl(url)))
        .retrieve()
        .onStatus(
            HttpStatusCode::isError,
            response -> response.bodyToMono(String.class).map(responseBody ->
                new InstitutionImportException(
                    "GOOGLE_HTTP_ERROR",
                    requestLabel + " HTTP " + response.statusCode().value(),
                    responseBody
                )
            )
        )
        .bodyToMono(String.class)
        .block();

    if (body == null || body.isBlank()) {
      throw new InstitutionImportException(
          "GOOGLE_EMPTY_RESPONSE",
          requestLabel + " returned an empty body.",
          ""
      );
    }

    try {
      JsonNode json = new com.fasterxml.jackson.databind.ObjectMapper().readTree(body);
      String status = textValue(json, "status");
      if (!"OK".equals(status) && !"ZERO_RESULTS".equals(status)) {
        String errorMessage = textValue(json, "error_message");
        throw new InstitutionImportException(
            mapGoogleStatusCode(status),
            requestLabel + " failed with Google status " + status
                + (errorMessage != null ? " (" + errorMessage + ")" : ""),
            body
        );
      }
      return json;
    } catch (InstitutionImportException ex) {
      throw ex;
    } catch (Exception ex) {
      throw new InstitutionImportException(
          "GOOGLE_PARSE_ERROR",
          requestLabel + " response could not be parsed.",
          body
      );
    }
  }

  private static String mapGoogleStatusCode(String status) {
    return switch (status) {
      case "REQUEST_DENIED" -> "GOOGLE_REQUEST_DENIED";
      case "OVER_QUERY_LIMIT" -> "GOOGLE_QUOTA_OR_BILLING_FAILURE";
      case "INVALID_REQUEST" -> "GOOGLE_INVALID_REQUEST";
      default -> "GOOGLE_API_ERROR";
    };
  }

  private static String textValue(JsonNode node, String field) {
    JsonNode value = node.path(field);
    if (value.isMissingNode() || value.isNull()) {
      return null;
    }
    String text = value.asText();
    return text == null || text.isBlank() ? null : text.trim();
  }

  private static String firstNonBlank(String first, String second) {
    if (first != null && !first.isBlank()) {
      return first;
    }
    if (second != null && !second.isBlank()) {
      return second;
    }
    return null;
  }

  public record ExternalPlaceSummary(
      String placeId,
      String name,
      double latitude,
      double longitude,
      String address,
      InstitutionType type
  ) {}

  public record ExternalPlaceDetails(
      String placeId,
      String name,
      String formattedAddress,
      String phone
  ) {}
}
