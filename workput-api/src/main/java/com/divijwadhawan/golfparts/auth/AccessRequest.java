package com.divijwadhawan.golfparts.auth;

import java.time.Instant;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

@Entity
@Table(name = "access_requests", uniqueConstraints =
        @UniqueConstraint(name = "uk_access_requests_google_sub", columnNames = "google_sub"))
public class AccessRequest {
    public enum Status { PENDING, APPROVED, REJECTED }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "google_sub", nullable = false, updatable = false)
    private String googleSub;

    private String email;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Status status;

    @Column(nullable = false)
    private Instant requestedAt;

    private Instant reviewedAt;
    private String reviewedBySub;

    protected AccessRequest() { }

    public AccessRequest(String googleSub, String email) {
        this.googleSub = googleSub;
        this.email = email;
        this.status = Status.PENDING;
        this.requestedAt = Instant.now();
    }

    public void resubmit(String email) {
        if (status == Status.REJECTED) {
            this.email = email;
            this.status = Status.PENDING;
            this.requestedAt = Instant.now();
            this.reviewedAt = null;
            this.reviewedBySub = null;
        }
    }

    public void approve(String reviewerSub) {
        this.status = Status.APPROVED;
        this.reviewedAt = Instant.now();
        this.reviewedBySub = reviewerSub;
    }

    public void reject(String reviewerSub) {
        this.status = Status.REJECTED;
        this.reviewedAt = Instant.now();
        this.reviewedBySub = reviewerSub;
    }

    public Long getId() { return id; }
    public String getGoogleSub() { return googleSub; }
    public String getEmail() { return email; }
    public Status getStatus() { return status; }
    public Instant getRequestedAt() { return requestedAt; }
    public Instant getReviewedAt() { return reviewedAt; }
    public String getReviewedBySub() { return reviewedBySub; }
}
