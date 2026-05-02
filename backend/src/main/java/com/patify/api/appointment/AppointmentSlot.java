package com.patify.api.appointment;

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
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import java.time.OffsetDateTime;

@Entity
@Table(
    name = "appointment_slots",
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_appointment_slots_veterinarian_start", columnNames = {
            "veterinarian_user_id",
            "start_time"
        })
    }
)
public class AppointmentSlot {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "veterinarian_user_id", nullable = false)
  private User veterinarian;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "institution_id", nullable = false)
  private Institution institution;

  @Column(name = "start_time", nullable = false)
  private OffsetDateTime startTime;

  @Column(name = "end_time", nullable = false)
  private OffsetDateTime endTime;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private AppointmentSlotStatus status = AppointmentSlotStatus.AVAILABLE;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "booked_by_user_id")
  private User bookedByUser;

  @Column(name = "booked_by_first_name")
  private String bookedByFirstName;

  @Column(name = "booked_by_last_name")
  private String bookedByLastName;

  @Column(name = "booked_by_email")
  private String bookedByEmail;

  @Column
  private String note;

  @Column(name = "cancellation_reason")
  private String cancellationReason;

  @Column(name = "cancelled_at")
  private OffsetDateTime cancelledAt;

  @Column(name = "cancellation_source")
  private String cancellationSource;

  @Column(name = "created_at", nullable = false)
  private OffsetDateTime createdAt;

  @Column(name = "updated_at", nullable = false)
  private OffsetDateTime updatedAt;

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

  public User getVeterinarian() {
    return veterinarian;
  }

  public void setVeterinarian(User veterinarian) {
    this.veterinarian = veterinarian;
  }

  public Institution getInstitution() {
    return institution;
  }

  public void setInstitution(Institution institution) {
    this.institution = institution;
  }

  public OffsetDateTime getStartTime() {
    return startTime;
  }

  public void setStartTime(OffsetDateTime startTime) {
    this.startTime = startTime;
  }

  public OffsetDateTime getEndTime() {
    return endTime;
  }

  public void setEndTime(OffsetDateTime endTime) {
    this.endTime = endTime;
  }

  public AppointmentSlotStatus getStatus() {
    return status;
  }

  public void setStatus(AppointmentSlotStatus status) {
    this.status = status;
  }

  public User getBookedByUser() {
    return bookedByUser;
  }

  public void setBookedByUser(User bookedByUser) {
    this.bookedByUser = bookedByUser;
  }

  public String getBookedByFirstName() {
    return bookedByFirstName;
  }

  public void setBookedByFirstName(String bookedByFirstName) {
    this.bookedByFirstName = bookedByFirstName;
  }

  public String getBookedByLastName() {
    return bookedByLastName;
  }

  public void setBookedByLastName(String bookedByLastName) {
    this.bookedByLastName = bookedByLastName;
  }

  public String getBookedByEmail() {
    return bookedByEmail;
  }

  public void setBookedByEmail(String bookedByEmail) {
    this.bookedByEmail = bookedByEmail;
  }

  public String getNote() {
    return note;
  }

  public void setNote(String note) {
    this.note = note;
  }

  public String getCancellationReason() {
    return cancellationReason;
  }

  public void setCancellationReason(String cancellationReason) {
    this.cancellationReason = cancellationReason;
  }

  public OffsetDateTime getCancelledAt() {
    return cancelledAt;
  }

  public void setCancelledAt(OffsetDateTime cancelledAt) {
    this.cancelledAt = cancelledAt;
  }

  public String getCancellationSource() {
    return cancellationSource;
  }

  public void setCancellationSource(String cancellationSource) {
    this.cancellationSource = cancellationSource;
  }

  public OffsetDateTime getCreatedAt() {
    return createdAt;
  }

  public OffsetDateTime getUpdatedAt() {
    return updatedAt;
  }
}
