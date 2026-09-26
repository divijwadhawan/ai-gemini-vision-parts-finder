package com.divijwadhawan.golfparts.catalog;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class CatalogService {

    private final CarPartRepository partRepository;
    private final AssemblyRepository assemblyRepository;

    public CatalogService(
            CarPartRepository partRepository,
            AssemblyRepository assemblyRepository
    ) {
        this.partRepository = partRepository;
        this.assemblyRepository = assemblyRepository;
    }

    public List<CarPartResponse> getPartsByAssemblyCode(String code) {

        Assembly assembly = assemblyRepository
                .findByCode(code)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Assembly not found"
                ));

        return partRepository.findByAssembly(assembly)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    public CarPartResponse createPart(CreateCarPartRequest request) {

        Assembly assembly = assemblyRepository
                .findByCode(request.assemblyCode())
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Assembly not found"
                ));

        CarPart part = new CarPart(
                assembly,
                request.name(),
                request.description(),
                request.referenceNumber(),
                request.calloutNumber(),
                request.quantity(),
                request.price(),
                request.imageIdentifier()
        );

        CarPart savedPart = partRepository.save(part);

        return toResponse(savedPart);
    }

    private CarPartResponse toResponse(CarPart part) {
        return new CarPartResponse(
                part.getId(),
                part.getAssembly().getCode(),
                part.getName(),
                part.getDescription(),
                part.getReferenceNumber(),
                part.getCalloutNumber(),
                part.getQuantity(),
                part.getPrice(),
                part.getImageIdentifier()
        );
    }

    public List<AssemblyResponse> getAssemblies() {

       return assemblyRepository.findAll()
            .stream()
            .map(this::toAssemblyResponse)
            .toList();
    }

    private AssemblyResponse toAssemblyResponse(Assembly assembly) {
       return new AssemblyResponse(
            assembly.getCode(),
            assembly.getName(),
            assembly.getDescription(),
            assembly.getDiagramImage()
        );
    }
}