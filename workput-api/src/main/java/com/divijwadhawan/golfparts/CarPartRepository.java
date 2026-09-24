package com.example.workout_api; // Use your actual package

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CarPartRepository extends JpaRepository<CarPart, Long> {

    List<CarPart> findByVehicleAndArea(String vehicle, String area);
}