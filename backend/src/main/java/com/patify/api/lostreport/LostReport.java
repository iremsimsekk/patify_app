package com.patify.api.lostreport;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;

@Entity
@Table(name = "lost_reports")
public class LostReport {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(name = "user_id", nullable = false)
  private Long userId;

  @Column(name = "pet_type", nullable = false)
  private String petType;

  @Column(nullable = false)
  private String description;

  @Column(name = "image_url")
  private String imageUrl;

  @Column(nullable = false)
  private Double latitude;

  @Column(nullable = false)
  private Double longitude;

  @Column(name = "seen_at", nullable = false)
  private OffsetDateTime seenAt;

  @Column(name = "contact_info", nullable = false)
  private String contactInfo;

  @Column(name = "district")
  private String district;

  @Column(name = "address")
  private String address;

  @Column(nullable = false)
  private String status = "ACTIVE";

  @Column(name = "notification_sent", nullable = false)
  private boolean notificationSent = false;

  @Column(name = "is_approved", nullable = false)
  private boolean approved = true;

  @Column(name = "created_at", nullable = false)
  private OffsetDateTime createdAt;

  @PrePersist
  void onCreate() {
    if (status == null || status.isBlank()) {
      status = "ACTIVE";
    }
    createdAt = createdAt == null ? OffsetDateTime.now() : createdAt;
  }

  public Long getId() {
    return id;
  }

  public Long getUserId() {
    return userId;
  }

  public void setUserId(Long userId) {
    this.userId = userId;
  }

  public String getPetType() {
    return petType;
  }

  public void setPetType(String petType) {
    this.petType = petType;
  }

  public String getDescription() {
    return description;
  }

  public void setDescription(String description) {
    this.description = description;
  }

  public String getImageUrl() {
    return imageUrl;
  }

  public void setImageUrl(String imageUrl) {
    this.imageUrl = imageUrl;
  }

  public Double getLatitude() {
    return latitude;
  }

  public void setLatitude(Double latitude) {
    this.latitude = latitude;
  }

  public Double getLongitude() {
    return longitude;
  }

  public void setLongitude(Double longitude) {
    this.longitude = longitude;
  }

  public OffsetDateTime getSeenAt() {
    return seenAt;
  }

  public void setSeenAt(OffsetDateTime seenAt) {
    this.seenAt = seenAt;
  }

  public String getContactInfo() {
    return contactInfo;
  }

  public void setContactInfo(String contactInfo) {
    this.contactInfo = contactInfo;
  }

  public String getDistrict() {
    return district;
  }

  public void setDistrict(String district) {
    this.district = district;
  }

  public String getAddress() {
    return address;
  }

  public void setAddress(String address) {
    this.address = address;
  }

  public String getStatus() {
    return status;
  }

  public void setStatus(String status) {
    this.status = status;
  }

  public boolean isNotificationSent() {
    return notificationSent;
  }

  public void setNotificationSent(boolean notificationSent) {
    this.notificationSent = notificationSent;
  }

  public boolean isApproved() {
    return approved;
  }

  public void setApproved(boolean approved) {
    this.approved = approved;
  }

  public OffsetDateTime getCreatedAt() {
    return createdAt;
  }
}
