package com.divijwadhawan.golfparts.catalog;

public record AssemblyResponse(
        String code,
        String name,
        String description,
        String diagramImage
) {}