package com.example.workout_api; // Replace with your actual package

import org.springframework.stereotype.Service;

@Service
public class WorkoutCalculator {

    public double paceMinutesPerKm(double distanceKm, double durationMinutes) {
        return durationMinutes / distanceKm;
    }

    public double speedKmPerHour(double distanceKm, double durationMinutes) {
        return distanceKm / (durationMinutes / 60);
    }
}