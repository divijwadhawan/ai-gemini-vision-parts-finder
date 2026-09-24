package com.divijwadhawan.golfparts;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface AccessRequestRepository extends JpaRepository<AccessRequest, Long> {
    Optional<AccessRequest> findByGoogleSub(String googleSub);
    List<AccessRequest> findAllByOrderByRequestedAtDesc();
}
