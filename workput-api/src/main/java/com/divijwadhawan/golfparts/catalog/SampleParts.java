package com.divijwadhawan.golfparts.catalog;

import java.math.BigDecimal;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SampleParts {

    @Bean
    CommandLineRunner addSampleParts(
            CarPartRepository partRepository,
            AssemblyRepository assemblyRepository) {

        return args -> {

            // Create the Front Bumper assembly if it does not already exist
            Assembly frontBumper = assemblyRepository
                    .findByCode("FRONT_BUMPER")
                    .orElseGet(() -> assemblyRepository.save(
                            new Assembly(
                                    "FRONT_BUMPER",
                                    "Front Bumper",
                                    "Front bumper assembly of the VW Golf 7",
                                    "front_bumper_diagram"
                            )
                    ));
            Assembly engine = assemblyRepository
                    .findByCode("ENGINE")
                    .orElseGet(() -> assemblyRepository.save(
                        new Assembly(
                                "ENGINE",
                                "Engine",
                                "Engine assembly of the VW Golf 7",
                                "engine_diagram"
                            )
                    ));        

            // If the database is completely empty, create sample parts
            if (partRepository.count() == 0) {

                partRepository.save(new CarPart(
                      frontBumper,
                "Bumper cover",
         "Visible outer cover of the front bumper",
     "5G0807217",
       1,
            1,
            new BigDecimal("199.99"),
            "front_bumper_cover"
                ));

                partRepository.save(new CarPart(
                      frontBumper,
                "Lower grille",
         "Opening in the lower front bumper area",
     "5G0853677",
        2,
             1,
             new BigDecimal("89.99"),
             "front_bumper_lower_grille"
));


                partRepository.save(new CarPart(
                      frontBumper,
                 "Bumper mounting bracket",
          "Support used to attach the bumper assembly",
      "5G0807183",
        3,
             1,
             new BigDecimal("39.99"),
             "front_bumper_mounting_bracket"
));
            }
        };
    }
}