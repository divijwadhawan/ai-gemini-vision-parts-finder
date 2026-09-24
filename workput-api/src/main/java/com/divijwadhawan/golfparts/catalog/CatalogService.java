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

    public List<CarPart> getPartsByAssemblyCode(String code) {

        Assembly assembly = assemblyRepository
                .findByCode(code)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Assembly not found"
                ));

        return partRepository.findByAssembly(assembly);
    }

    public CarPart createPart(CreateCarPartRequest request) {

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

        return partRepository.save(part);
    }
}