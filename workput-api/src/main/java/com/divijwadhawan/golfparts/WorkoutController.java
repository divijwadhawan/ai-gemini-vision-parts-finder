package com.divijwadhawan.golfparts;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;
import java.util.Map;

@RestController

public class WorkoutController {

    @GetMapping("/hello")
    public String hello() {
        return "Workout API is running!";
    }

    private final WorkoutCalculator calculator;

    public WorkoutController(WorkoutCalculator calculator) {
    this.calculator = calculator;
    }

    @GetMapping("/workouts/pace")
    public Map<String, Double> calculatePace(
            @RequestParam double distanceKm,
            @RequestParam double durationMinutes) {

        if (distanceKm <= 0 || durationMinutes <= 0) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Distance and duration must be greater than zero"
            );
        }

        return Map.of(
                "paceMinutesPerKm",
                calculator.paceMinutesPerKm(distanceKm, durationMinutes),
                "speedKmPerHour",
                calculator.speedKmPerHour(distanceKm, durationMinutes)
        );
    }
}