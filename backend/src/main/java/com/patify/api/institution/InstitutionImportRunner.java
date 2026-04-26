package com.patify.api.institution;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

@Component
public class InstitutionImportRunner implements ApplicationRunner {
  private static final Logger log = LoggerFactory.getLogger(InstitutionImportRunner.class);

  private final InstitutionImportService institutionImportService;

  @Value("${patify.import.institutions:false}")
  private boolean importEnabled;

  @Value("${patify.import.exit-on-complete:true}")
  private boolean exitOnComplete;

  @Value("${patify.import.source:google}")
  private String importSource;

  @Value("${patify.import.json.clinics:classpath:import-data/ankara_veterinary_google_legacy.json}")
  private String clinicsJsonResource;

  @Value("${patify.import.json.shelters:classpath:import-data/ankara_shelters_clean_google_legacy.json}")
  private String sheltersJsonResource;

  public InstitutionImportRunner(InstitutionImportService institutionImportService) {
    this.institutionImportService = institutionImportService;
  }

  @Override
  public void run(ApplicationArguments args) {
    if (!importEnabled) {
      return;
    }

    int exitCode = 0;
    try {
      InstitutionImportService.ImportResult result = "json".equalsIgnoreCase(importSource)
          ? institutionImportService.importInstitutionsFromJson(clinicsJsonResource, sheltersJsonResource)
          : institutionImportService.importInstitutions();
      log.info(
          "IMPORT_SUCCESS source={} clinicsImported={} sheltersImported={} shelterRecordsSkipped={} inserted={} updated={}",
          importSource,
          result.clinicsImported(),
          result.sheltersImported(),
          result.shelterRecordsSkipped(),
          result.inserted(),
          result.updated()
      );
    } catch (InstitutionImportException ex) {
      exitCode = 1;
      log.error(
          "IMPORT_FAILED code={} reason={} details={}",
          ex.getCode(),
          ex.getMessage(),
          ex.getDetails()
      );
    } catch (Exception ex) {
      exitCode = 1;
      log.error("IMPORT_FAILED code=UNEXPECTED_ERROR reason={}", ex.getMessage(), ex);
    }

    if (exitOnComplete) {
      System.exit(exitCode);
    }
  }
}
