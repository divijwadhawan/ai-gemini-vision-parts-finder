package com.divijwadhawan.golfparts.catalog;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;

import java.math.BigDecimal;

@Entity
public class CarPart {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "assembly_id")
    private Assembly assembly;

    private String name;
    private String description;
    private String referenceNumber;
    private Integer calloutNumber;
    private Integer quantity;
    private BigDecimal price;
    private String imageIdentifier;


    protected CarPart() {
        // Required by JPA
    }

    public CarPart(
        Assembly assembly,
        String name,
        String description,
        String referenceNumber,
        Integer calloutNumber,
        Integer quantity,
        BigDecimal price,
        String imageIdentifier
    ) {
    this.assembly = assembly;
    this.name = name;
    this.description = description;
    this.referenceNumber = referenceNumber;
    this.calloutNumber = calloutNumber;
    this.quantity = quantity;
    this.price = price;
    this.imageIdentifier = imageIdentifier;
    }

    public Long getId() {
        return id;
    }

    public Assembly getAssembly() {
        return assembly;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public String getReferenceNumber() {
        return referenceNumber;
    }

    public Integer getCalloutNumber() {
        return calloutNumber;
    }

    public void assignToAssembly(Assembly assembly) {
        this.assembly = assembly;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public String getImageIdentifier() {
        return imageIdentifier;
    }
}