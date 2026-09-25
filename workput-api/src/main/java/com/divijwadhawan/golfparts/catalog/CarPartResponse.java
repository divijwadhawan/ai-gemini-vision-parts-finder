package com.divijwadhawan.golfparts.catalog;

import java.math.BigDecimal;

public record CarPartResponse(
        Long id,
        String assemblyCode,
        String name,
        String description,
        String referenceNumber,
        Integer calloutNumber,
        Integer quantity,
        BigDecimal price,
        String imageIdentifier
) {}