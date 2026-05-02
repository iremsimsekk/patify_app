package com.patify.api.veterinarian;

import com.patify.api.auth.EmailService;
import com.patify.api.auth.JwtService;
import com.patify.api.auth.Role;
import com.patify.api.auth.User;
import com.patify.api.auth.UserRepository;
import com.patify.api.institution.Institution;
import com.patify.api.institution.InstitutionLocation;
import com.patify.api.institution.InstitutionRepository;
import com.patify.api.institution.InstitutionType;
import io.jsonwebtoken.JwtException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class VeterinarianClaimService {
  private static final List<String> VETERINARY_TYPES = List.of(
      InstitutionType.VETERINARY.dbValue(),
      InstitutionType.CLINIC.dbValue()
  );

  private final VeterinaryClaimRequestRepository claimRequests;
  private final InstitutionRepository institutions;
  private final UserRepository users;
  private final JwtService jwtService;
  private final EmailService emailService;
  private final String adminEmail;
  private final String publicBaseUrl;

  public VeterinarianClaimService(
      VeterinaryClaimRequestRepository claimRequests,
      InstitutionRepository institutions,
      UserRepository users,
      JwtService jwtService,
      EmailService emailService,
      @Value("${app.veterinarianApproval.adminEmail:asko.team.777@gmail.com}") String adminEmail,
      @Value("${app.publicBaseUrl:http://localhost:8080}") String publicBaseUrl
  ) {
    this.claimRequests = claimRequests;
    this.institutions = institutions;
    this.users = users;
    this.jwtService = jwtService;
    this.emailService = emailService;
    this.adminEmail = adminEmail;
    this.publicBaseUrl = publicBaseUrl;
  }

  public ClaimStatusResponse getClaimStatus(String authorizationHeader) {
    User veterinarian = requireVeterinarian(authorizationHeader);
    return claimRequests.findTopByUserIdOrderByCreatedAtDesc(veterinarian.id)
        .map(this::toStatusResponse)
        .orElseGet(() -> new ClaimStatusResponse("NONE", null));
  }

  public List<InstitutionSearchResponse> searchInstitutions(
      String authorizationHeader,
      String query
  ) {
    requireVeterinarian(authorizationHeader);
    String normalizedQuery = query == null ? "" : query.trim();
    List<Institution> results = normalizedQuery.isBlank()
        ? institutions.findVeterinaryInstitutions(VETERINARY_TYPES, PageRequest.of(0, 20))
        : institutions.searchVeterinaryInstitutions(
            VETERINARY_TYPES,
            normalizedQuery,
            PageRequest.of(0, 20)
        );

    return results.stream()
        .map(this::toInstitutionSearchResponse)
        .toList();
  }

  @Transactional
  public ClaimStatusResponse createClaimRequest(
      String authorizationHeader,
      CreateClaimRequest request
  ) {
    User veterinarian = requireVeterinarian(authorizationHeader);
    Institution institution = institutions.findByIdAndDeletedAtIsNull(request.institutionId())
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "INSTITUTION_NOT_FOUND"));

    if (!VETERINARY_TYPES.contains(institution.getType().toLowerCase())) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "INSTITUTION_NOT_VETERINARY");
    }

    claimRequests.findTopByUserIdAndInstitutionIdAndStatusOrderByCreatedAtDesc(
            veterinarian.id,
            institution.getId(),
            VeterinaryClaimStatus.PENDING
        )
        .ifPresent(existing -> {
          throw new ResponseStatusException(
              HttpStatus.CONFLICT,
              "CLAIM_REQUEST_ALREADY_PENDING"
          );
        });

    VeterinaryClaimRequest claim = new VeterinaryClaimRequest();
    claim.setUser(veterinarian);
    claim.setInstitution(institution);
    claim.setStatus(VeterinaryClaimStatus.PENDING);
    claim.setRequestNote(request.requestNote() == null ? null : request.requestNote().trim());
    claim.setApprovalToken(UUID.randomUUID().toString());
    claim.setRejectionToken(UUID.randomUUID().toString());
    claimRequests.save(claim);

    String approveUrl = buildDecisionUrl(claim.getId(), "approve", claim.getApprovalToken());
    String rejectUrl = buildDecisionUrl(claim.getId(), "reject", claim.getRejectionToken());

    emailService.sendVeterinarianApprovalEmail(
        adminEmail,
        veterinarian.email,
        institution.getName(),
        institution.getAddress(),
        institution.getEmail(),
        approveUrl,
        rejectUrl
    );

    return toStatusResponse(claim);
  }

  @Transactional
  public String approveClaim(long id, String token) {
    VeterinaryClaimRequest claim = claimRequests.findById(id)
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "CLAIM_REQUEST_NOT_FOUND"));
    validateDecisionToken(claim.getApprovalToken(), token);
    return reviewClaim(claim, VeterinaryClaimStatus.APPROVED, "Veteriner sahiplenme talebi onaylandı.");
  }

  @Transactional
  public String rejectClaim(long id, String token) {
    VeterinaryClaimRequest claim = claimRequests.findById(id)
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "CLAIM_REQUEST_NOT_FOUND"));
    validateDecisionToken(claim.getRejectionToken(), token);
    return reviewClaim(claim, VeterinaryClaimStatus.REJECTED, "Veteriner sahiplenme talebi reddedildi.");
  }

  private String reviewClaim(
      VeterinaryClaimRequest claim,
      VeterinaryClaimStatus newStatus,
      String successMessage
  ) {
    if (claim.getStatus() != VeterinaryClaimStatus.PENDING) {
      return "Bu talep zaten " + claim.getStatus().name() + " durumuna alınmış.";
    }

    claim.setStatus(newStatus);
    claim.setReviewedAt(OffsetDateTime.now());
    claimRequests.save(claim);
    return successMessage;
  }

  private void validateDecisionToken(String expectedToken, String actualToken) {
    if (actualToken == null || actualToken.isBlank() || !expectedToken.equals(actualToken)) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "INVALID_CLAIM_TOKEN");
    }
  }

  private String buildDecisionUrl(long id, String action, String token) {
    return publicBaseUrl
        + "/api/veterinarian/claim-requests/"
        + id
        + "/"
        + action
        + "?token="
        + URLEncoder.encode(token, StandardCharsets.UTF_8);
  }

  private User requireVeterinarian(String authorizationHeader) {
    String token = extractBearerToken(authorizationHeader);
    final String email;
    final Role role;
    try {
      email = jwtService.extractEmail(token);
      role = jwtService.extractRole(token);
    } catch (JwtException | IllegalArgumentException ex) {
      throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "INVALID_AUTH_TOKEN");
    }

    if (role != Role.VETERINARIAN) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "VETERINARIAN_ROLE_REQUIRED");
    }

    return users.findByEmail(email.toLowerCase().trim())
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "USER_NOT_FOUND"));
  }

  private String extractBearerToken(String authorizationHeader) {
    if (authorizationHeader == null || !authorizationHeader.startsWith("Bearer ")) {
      throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "AUTHORIZATION_REQUIRED");
    }
    String token = authorizationHeader.substring("Bearer ".length()).trim();
    if (token.isEmpty()) {
      throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "AUTHORIZATION_REQUIRED");
    }
    return token;
  }

  private ClaimStatusResponse toStatusResponse(VeterinaryClaimRequest claim) {
    return new ClaimStatusResponse(
        claim.getStatus().name(),
        toInstitutionSummary(claim.getInstitution())
    );
  }

  private InstitutionSearchResponse toInstitutionSearchResponse(Institution institution) {
    InstitutionLocation location = institution.getLocation();
    return new InstitutionSearchResponse(
        institution.getId(),
        institution.getName(),
        institution.getAddress(),
        institution.getEmail(),
        location != null ? location.getLatitude() : null,
        location != null ? location.getLongitude() : null
    );
  }

  private InstitutionSummaryResponse toInstitutionSummary(Institution institution) {
    InstitutionLocation location = institution.getLocation();
    return new InstitutionSummaryResponse(
        institution.getId(),
        institution.getName(),
        institution.getAddress(),
        institution.getEmail(),
        institution.getPhone(),
        institution.getWebsite(),
        institution.getDescription(),
        institution.getOpeningHours(),
        institution.getCity(),
        institution.getDistrict(),
        location != null ? location.getLatitude() : null,
        location != null ? location.getLongitude() : null
    );
  }

  public record CreateClaimRequest(Long institutionId, String requestNote) {}

  public record ClaimStatusResponse(String status, InstitutionSummaryResponse institution) {}

  public record InstitutionSummaryResponse(
      Long id,
      String name,
      String address,
      String email,
      String phone,
      String website,
      String description,
      String openingHours,
      String city,
      String district,
      Double latitude,
      Double longitude
  ) {}

  public record InstitutionSearchResponse(
      Long id,
      String name,
      String address,
      String email,
      Double latitude,
      Double longitude
  ) {}
}
