package com.example.workout_api;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface AccessRequestRepository extends JpaRepository<AccessRequest, Long> {
    Optional<AccessRequest> findByGoogleSub(String googleSub);
    List<AccessRequest> findAllByOrderByRequestedAtDesc();
}
