package com.patify.api.veterinarian;

import com.patify.api.auth.User;
import com.patify.api.institution.Institution;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;

@Entity
@Table(name = "veterinary_claim_requests")
public class VeterinaryClaimRequest {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "user_id", nullable = false)
  private User user;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "institution_id", nullable = false)
  private Institution institution;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private VeterinaryClaimStatus status;

  @Column(name = "request_note")
  private String requestNote;

  @Column(name = "approval_token", nullable = false)
  private String approvalToken;

  @Column(name = "rejection_token", nullable = false)
  private String rejectionToken;

  @Column(name = "created_at", nullable = false)
  private OffsetDateTime createdAt;

  @Column(name = "reviewed_at")
  private OffsetDateTime reviewedAt;

  @PrePersist
  void onCreate() {
    if (createdAt == null) {
      createdAt = OffsetDateTime.now();
    }
  }

  public Long getId() {
    return id;
  }

  public User getUser() {
    return user;
  }

  public void setUser(User user) {
    this.user = user;
  }

  public Institution getInstitution() {
    return institution;
  }

  public void setInstitution(Institution institution) {
    this.institution = institution;
  }

  public VeterinaryClaimStatus getStatus() {
    return status;
  }

  public void setStatus(VeterinaryClaimStatus status) {
    this.status = status;
  }

  public String getRequestNote() {
    return requestNote;
  }

  public void setRequestNote(String requestNote) {
    this.requestNote = requestNote;
  }

  public String getApprovalToken() {
    return approvalToken;
  }

  public void setApprovalToken(String approvalToken) {
    this.approvalToken = approvalToken;
  }

  public String getRejectionToken() {
    return rejectionToken;
  }

  public void setRejectionToken(String rejectionToken) {
    this.rejectionToken = rejectionToken;
  }

  public OffsetDateTime getCreatedAt() {
    return createdAt;
  }

  public OffsetDateTime getReviewedAt() {
    return reviewedAt;
  }

  public void setReviewedAt(OffsetDateTime reviewedAt) {
    this.reviewedAt = reviewedAt;
  }
}
