package com.divijwadhawan.golfparts.scan;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

public interface ScanRepository extends JpaRepository<Scan, Long> {

    List<Scan> findByGoogleSubOrderByCreatedAtDesc(String googleSub);
}