package com.divijwadhawan.golfparts.catalog;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface AssemblyRepository extends JpaRepository<Assembly, Long> {

    Optional<Assembly> findByCode(String code);
}