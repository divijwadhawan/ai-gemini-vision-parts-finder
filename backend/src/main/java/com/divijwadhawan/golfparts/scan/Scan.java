package com.divijwadhawan.golfparts.scan;

import java.time.Instant;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "scans")
public class Scan {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String googleSub;
    private String assemblyCode;

    private double confidence;

    private double boundingBoxX;
    private double boundingBoxY;
    private double boundingBoxWidth;
    private double boundingBoxHeight;

    private Instant createdAt;

    protected Scan() {
    }

    public Scan(
            String googleSub,
            String assemblyCode,
            double confidence,
            double boundingBoxX,
            double boundingBoxY,
            double boundingBoxWidth,
            double boundingBoxHeight
    ) {
        this.googleSub = googleSub;
        this.assemblyCode = assemblyCode;
        this.confidence = confidence;
        this.boundingBoxX = boundingBoxX;
        this.boundingBoxY = boundingBoxY;
        this.boundingBoxWidth = boundingBoxWidth;
        this.boundingBoxHeight = boundingBoxHeight;
        this.createdAt = Instant.now();
    }

    public Long getId() {
        return id;
    }

    public String getGoogleSub() {
        return googleSub;
    }

    public String getAssemblyCode() {
        return assemblyCode;
    }

    public double getConfidence() {
        return confidence;
    }

    public double getBoundingBoxX() {
        return boundingBoxX;
    }

    public double getBoundingBoxY() {
        return boundingBoxY;
    }

    public double getBoundingBoxWidth() {
        return boundingBoxWidth;
    }

    public double getBoundingBoxHeight() {
        return boundingBoxHeight;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
}