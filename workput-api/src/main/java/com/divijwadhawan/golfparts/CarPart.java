package com.divijwadhawan.golfparts; // Use your actual package

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

@Entity
public class CarPart {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String vehicle;
    private String area;
    private String name;
    private String description;

    protected CarPart() {
        // Required by JPA
    }

    public CarPart(String vehicle, String area, String name, String description) {
        this.vehicle = vehicle;
        this.area = area;
        this.name = name;
        this.description = description;
    }

    public Long getId() { return id; }
    public String getVehicle() { return vehicle; }
    public String getArea() { return area; }
    public String getName() { return name; }
    public String getDescription() { return description; }
}