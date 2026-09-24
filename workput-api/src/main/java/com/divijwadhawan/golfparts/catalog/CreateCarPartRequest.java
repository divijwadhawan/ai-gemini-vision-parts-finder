package com.divijwadhawan.golfparts.catalog;

import java.math.BigDecimal;

public record CreateCarPartRequest(

        String assemblyCode,

        String name,

        String description,

        String referenceNumber,

        Integer calloutNumber,

        Integer quantity,

        BigDecimal price,

        String imageIdentifier

) {}