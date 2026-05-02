package com.patify.api.veterinarian;

import java.util.List;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/veterinarian")
public class VeterinarianClaimController {
  private final VeterinarianClaimService claimService;

  public VeterinarianClaimController(VeterinarianClaimService claimService) {
    this.claimService = claimService;
  }

  @GetMapping("/claim-status")
  public VeterinarianClaimService.ClaimStatusResponse getClaimStatus(
      @RequestHeader(value = "Authorization", required = false) String authorizationHeader
  ) {
    return claimService.getClaimStatus(authorizationHeader);
  }

  @PostMapping("/claim-requests")
  public VeterinarianClaimService.ClaimStatusResponse createClaimRequest(
      @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
      @RequestBody VeterinarianClaimService.CreateClaimRequest request
  ) {
    return claimService.createClaimRequest(authorizationHeader, request);
  }

  @GetMapping(value = "/claim-requests/{id}/approve", produces = MediaType.TEXT_HTML_VALUE)
  public String approveClaim(
      @PathVariable long id,
      @RequestParam String token
  ) {
    return wrapHtml(claimService.approveClaim(id, token));
  }

  @GetMapping(value = "/claim-requests/{id}/reject", produces = MediaType.TEXT_HTML_VALUE)
  public String rejectClaim(
      @PathVariable long id,
      @RequestParam String token
  ) {
    return wrapHtml(claimService.rejectClaim(id, token));
  }

  @GetMapping("/institutions/search")
  public List<VeterinarianClaimService.InstitutionSearchResponse> searchInstitutions(
      @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
      @RequestParam(required = false, defaultValue = "") String query
  ) {
    return claimService.searchInstitutions(authorizationHeader, query);
  }

  private String wrapHtml(String message) {
    return """
        <!doctype html>
        <html lang="tr">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title>Patify Veteriner Talebi</title>
          <style>
            body { font-family: Arial, Helvetica, sans-serif; background: #F6F1EA; color: #2F2A28; display: grid; place-items: center; min-height: 100vh; margin: 0; padding: 24px; }
            main { max-width: 520px; background: #FFFCF8; border: 1px solid #E7DED5; border-radius: 20px; padding: 32px; text-align: center; box-shadow: 0 16px 48px rgba(47, 42, 40, 0.08); }
            h1 { margin: 0 0 12px; font-size: 26px; }
            p { margin: 0; font-size: 16px; line-height: 1.6; color: #6B625D; }
          </style>
        </head>
        <body>
          <main>
            <h1>Patify</h1>
            <p>%s</p>
          </main>
        </body>
        </html>
        """.formatted(message);
  }
}
