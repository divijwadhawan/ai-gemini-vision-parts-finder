package com.example.workout_api; // Use your actual package

public record CreateCarPartRequest(
        String vehicle,
        String area,
        String name,
        String description
) {}