package com.divijwadhawan.golfparts; // Use your actual package

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SampleParts {

    @Bean
    CommandLineRunner addSampleParts(CarPartRepository repository) {
        return args -> {
            if (repository.count() == 0) {
                repository.save(new CarPart(
                    "golf-7", "front-bumper", "Bumper cover",
                    "Visible outer cover of the front bumper"
                ));
                repository.save(new CarPart(
                    "golf-7", "front-bumper", "Lower grille",
                    "Opening in the lower front bumper area"
                ));
                repository.save(new CarPart(
                    "golf-7", "front-bumper", "Bumper mounting bracket",
                    "Support used to attach the bumper assembly"
                ));
                repository.save(new CarPart(
                    "golf-7", "engine-bay", "Main Motor",
                    "Used to start the vehicle"
                ));
                repository.save(new CarPart(
                    "golf-7", "engine-bay", "Oil Filter",
                    "Used to filter oil for engine use"
                ));
            }
        };
    }
}