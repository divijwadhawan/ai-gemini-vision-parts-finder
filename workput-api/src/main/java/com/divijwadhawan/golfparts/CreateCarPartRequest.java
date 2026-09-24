package com.divijwadhawan.golfparts; // Use your actual package

public record CreateCarPartRequest(
        String vehicle,
        String area,
        String name,
        String description
) {}