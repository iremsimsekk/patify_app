package com.patify.api.institution;

public enum InstitutionType {
  CLINIC("clinic", "vet"),
  VETERINARY("veterinary", "vet"),
  SHELTER("shelter", "shelter");

  private final String dbValue;
  private final String apiCategory;

  InstitutionType(String dbValue, String apiCategory) {
    this.dbValue = dbValue;
    this.apiCategory = apiCategory;
  }

  public String dbValue() {
    return dbValue;
  }

  public String apiCategory() {
    return apiCategory;
  }

  public static InstitutionType fromDbValue(String value) {
    for (InstitutionType type : values()) {
      if (type.dbValue.equalsIgnoreCase(value)) {
        return type;
      }
    }
    throw new IllegalArgumentException("Unsupported institution type: " + value);
  }
}
