package com.divijwadhawan.golfparts.catalog;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CarPartRepository extends JpaRepository<CarPart, Long> {

    List<CarPart> findByAssembly(Assembly assembly);
}