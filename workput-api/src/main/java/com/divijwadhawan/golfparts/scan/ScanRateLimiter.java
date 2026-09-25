package com.divijwadhawan.golfparts.scan;

import java.time.Duration;
import java.time.Instant;
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.stereotype.Component;

@Component
public class ScanRateLimiter {

    private static final int MAX_SCANS = 5;
    private static final Duration WINDOW =
            Duration.ofMinutes(1);

    private final Map<String, Deque<Instant>> requests =
            new ConcurrentHashMap<>();

    public boolean allow(String googleSub) {

        Instant now = Instant.now();
        Instant windowStart = now.minus(WINDOW);

        Deque<Instant> userRequests =
                requests.computeIfAbsent(
                        googleSub,
                        key -> new ArrayDeque<>()
                );

        synchronized (userRequests) {

            while (!userRequests.isEmpty()
                    && userRequests.peekFirst()
                            .isBefore(windowStart)) {

                userRequests.removeFirst();
            }

            if (userRequests.size() >= MAX_SCANS) {
                return false;
            }

            userRequests.addLast(now);

            return true;
        }
    }
}