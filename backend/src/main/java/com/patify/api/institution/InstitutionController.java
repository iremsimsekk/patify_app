package com.patify.api.institution;

import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/institutions")
public class InstitutionController {
  private final InstitutionService institutionService;

  public InstitutionController(InstitutionService institutionService) {
    this.institutionService = institutionService;
  }

  @GetMapping
  public List<InstitutionService.InstitutionSummaryResponse> list(
      @RequestParam String type
  ) {
    return institutionService.listByType(type);
  }

  @GetMapping("/{id}")
  public InstitutionService.InstitutionDetailResponse getById(@PathVariable long id) {
    return institutionService.getById(id);
  }
}
