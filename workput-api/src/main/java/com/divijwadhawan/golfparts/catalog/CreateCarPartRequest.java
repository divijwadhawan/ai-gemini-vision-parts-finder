package com.divijwadhawan.golfparts.catalog;

import java.math.BigDecimal;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record CreateCarPartRequest(

        @NotBlank
        String assemblyCode,

        @NotBlank
        String name,

        String description,

        @NotBlank
        String referenceNumber,

        @NotNull
        @Min(1)
        Integer calloutNumber,

        @NotNull
        @Min(1)
        Integer quantity,

        @NotNull
        @DecimalMin("0.0")
        BigDecimal price,

        String imageIdentifier

) {}