package com.divijwadhawan.golfparts; // Use your actual package

import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import org.springframework.web.bind.annotation.PathVariable;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.server.ResponseStatusException;

@RestController
public class CarPartController {

    private final CarPartRepository repository;

    public CarPartController(CarPartRepository repository) {
        this.repository = repository;
    }

    @GetMapping("/vehicles/{vehicle}/areas/{area}/parts")
    public List<CarPart> getParts(
        @PathVariable String vehicle,
        @PathVariable String area) {

    return repository.findByVehicleAndArea(vehicle, area);
    }

    @PostMapping("/parts")
    @ResponseStatus(HttpStatus.CREATED)
    public CarPart createPart(@RequestBody CreateCarPartRequest request) {
        if (request.vehicle() == null || request.vehicle().isBlank()
                || request.area() == null || request.area().isBlank()
                || request.name() == null || request.name().isBlank()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Vehicle, area, and name are required"
            );
        }

        CarPart part = new CarPart(
                request.vehicle(),
                request.area(),
                request.name(),
                request.description()
        );

        return repository.save(part);
    }
}