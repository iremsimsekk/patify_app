package com.patify.api.institution;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;

@Entity
@Table(name = "institutions")
public class Institution {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false)
  private String type;

  @Column(nullable = false)
  private String name;

  @Column
  private String phone;

  @Column(name = "international_phone_number")
  private String internationalPhoneNumber;

  @Column
  private String address;

  @Column
  private String district;

  @Column
  private String website;

  @Column(name = "opening_hours")
  private String openingHours;

  @Column
  private Double rating;

  @Column(name = "user_rating_count")
  private Integer userRatingCount;

  @Column(name = "google_maps_url")
  private String googleMapsUrl;

  @Column(name = "description")
  private String description;

  @Column(name = "external_source_id")
  private String externalSourceId;

  @Column(name = "created_at", nullable = false)
  private OffsetDateTime createdAt;

  @Column(name = "updated_at", nullable = false)
  private OffsetDateTime updatedAt;

  @Column(name = "deleted_at")
  private OffsetDateTime deletedAt;

  @OneToOne(mappedBy = "institution", fetch = FetchType.LAZY, cascade = CascadeType.ALL, orphanRemoval = true)
  private InstitutionLocation location;

  @PrePersist
  void onCreate() {
    OffsetDateTime now = OffsetDateTime.now();
    if (createdAt == null) {
      createdAt = now;
    }
    updatedAt = now;
  }

  @PreUpdate
  void onUpdate() {
    updatedAt = OffsetDateTime.now();
  }

  public Long getId() {
    return id;
  }

  public String getType() {
    return type;
  }

  public void setType(String type) {
    this.type = type;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public String getPhone() {
    return phone;
  }

  public void setPhone(String phone) {
    this.phone = phone;
  }

  public String getInternationalPhoneNumber() {
    return internationalPhoneNumber;
  }

  public void setInternationalPhoneNumber(String internationalPhoneNumber) {
    this.internationalPhoneNumber = internationalPhoneNumber;
  }

  public String getAddress() {
    return address;
  }

  public void setAddress(String address) {
    this.address = address;
  }

  public String getDistrict() {
    return district;
  }

  public void setDistrict(String district) {
    this.district = district;
  }

  public String getWebsite() {
    return website;
  }

  public void setWebsite(String website) {
    this.website = website;
  }

  public String getOpeningHours() {
    return openingHours;
  }

  public void setOpeningHours(String openingHours) {
    this.openingHours = openingHours;
  }

  public Double getRating() {
    return rating;
  }

  public void setRating(Double rating) {
    this.rating = rating;
  }

  public Integer getUserRatingCount() {
    return userRatingCount;
  }

  public void setUserRatingCount(Integer userRatingCount) {
    this.userRatingCount = userRatingCount;
  }

  public String getGoogleMapsUrl() {
    return googleMapsUrl;
  }

  public void setGoogleMapsUrl(String googleMapsUrl) {
    this.googleMapsUrl = googleMapsUrl;
  }

  public String getDescription() {
    return description;
  }

  public void setDescription(String description) {
    this.description = description;
  }

  public String getExternalSourceId() {
    return externalSourceId;
  }

  public void setExternalSourceId(String externalSourceId) {
    this.externalSourceId = externalSourceId;
  }

  public OffsetDateTime getCreatedAt() {
    return createdAt;
  }

  public OffsetDateTime getUpdatedAt() {
    return updatedAt;
  }

  public OffsetDateTime getDeletedAt() {
    return deletedAt;
  }

  public InstitutionLocation getLocation() {
    return location;
  }

  public void setLocation(InstitutionLocation location) {
    this.location = location;
  }
}
