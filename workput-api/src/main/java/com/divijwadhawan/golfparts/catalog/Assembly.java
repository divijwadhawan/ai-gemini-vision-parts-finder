package com.divijwadhawan.golfparts.catalog;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "assemblies")
public class Assembly {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String code;
    private String name;
    private String description;
    private String diagramImage;

    protected Assembly() {
        // Required by JPA
    }

    public Assembly(
            String code,
            String name,
            String description,
            String diagramImage
    ) {
        this.code = code;
        this.name = name;
        this.description = description;
        this.diagramImage = diagramImage;
    }

    public Long getId() {
        return id;
    }

    public String getCode() {
        return code;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public String getDiagramImage() {
        return diagramImage;
    }
}