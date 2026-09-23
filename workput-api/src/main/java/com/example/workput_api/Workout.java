package com.example.workout_api; // Replace with your actual package

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

@Entity
public class Workout {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private double distanceKm;
    private double durationMinutes;

    protected Workout() {
        // JPA needs a no-argument constructor
    }

    public Workout(double distanceKm, double durationMinutes) {
        this.distanceKm = distanceKm;
        this.durationMinutes = durationMinutes;
    }

    public Long getId() {
        return id;
    }

    public double getDistanceKm() {
        return distanceKm;
    }

    public double getDurationMinutes() {
        return durationMinutes;
    }
}