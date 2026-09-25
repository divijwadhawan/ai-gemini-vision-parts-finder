package com.divijwadhawan.golfparts.catalog;

import java.util.List;

import jakarta.validation.Valid;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class CarPartController {

    private final CatalogService catalogService;

    public CarPartController(CatalogService catalogService) {
        this.catalogService = catalogService;
    }

    @GetMapping("/assemblies/{code}/parts")
    public List<CarPartResponse> getPartsByAssembly(@PathVariable String code) {
        return catalogService.getPartsByAssemblyCode(code);
    }

    @GetMapping("/assemblies")
    public List<AssemblyResponse> getAssemblies() {
        return catalogService.getAssemblies();
    }

    @PostMapping("/parts")
    @ResponseStatus(HttpStatus.CREATED)
    public CarPartResponse createPart(
            @Valid @RequestBody CreateCarPartRequest request) {

        return catalogService.createPart(request);
    }
}