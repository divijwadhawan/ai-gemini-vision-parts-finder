package com.divijwadhawan.golfparts.common;

public record ApiError(
        String code,
        String message
) {
}