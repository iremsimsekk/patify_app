package com.patify.api.institution;

public class InstitutionImportException extends RuntimeException {
  private final String code;
  private final String details;

  public InstitutionImportException(String code, String message, String details) {
    super(message);
    this.code = code;
    this.details = details;
  }

  public String getCode() {
    return code;
  }

  public String getDetails() {
    return details;
  }
}
