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
            AssemblyRepository assemblyRepository
    ) {
        return args -> {

            // =================================================
            // ASSEMBLIES
            // =================================================

            Assembly frontBumper = assemblyRepository
                    .findByCode("FRONT_BUMPER")
                    .orElseGet(() -> assemblyRepository.save(
                            new Assembly(
                                    "FRONT_BUMPER",
                                    "Front Bumper",
                                    "Front bumper assembly",
                                    "front_bumper_diagram"
                            )
                    ));

            Assembly engine = assemblyRepository
                    .findByCode("ENGINE")
                    .orElseGet(() -> assemblyRepository.save(
                            new Assembly(
                                    "ENGINE",
                                    "Engine",
                                    "Engine and engine-bay assembly",
                                    "engine_diagram"
                            )
                    ));

            Assembly rearBumper = assemblyRepository
                    .findByCode("REAR_BUMPER")
                    .orElseGet(() -> assemblyRepository.save(
                            new Assembly(
                                    "REAR_BUMPER",
                                    "Rear Bumper",
                                    "Rear bumper assembly",
                                    "rear_bumper_diagram"
                            )
                    ));

            Assembly sideMirror = assemblyRepository
                    .findByCode("SIDE_MIRROR")
                    .orElseGet(() -> assemblyRepository.save(
                            new Assembly(
                                    "SIDE_MIRROR",
                                    "Side Mirror",
                                    "Exterior side mirror assembly",
                                    "side_mirror_diagram"
                            )
                    ));

            Assembly door = assemblyRepository
                    .findByCode("DOOR")
                    .orElseGet(() -> assemblyRepository.save(
                            new Assembly(
                                    "DOOR",
                                    "Door",
                                    "Vehicle door assembly",
                                    "door_diagram"
                            )
                    ));


            // =================================================
            // FRONT BUMPER
            // =================================================

            addPartIfMissing(partRepository, frontBumper,
                    "Front bumper cover",
                    "Visible outer cover of the front bumper",
                    "DEMO-FB-001",
                    1, 1,
                    new BigDecimal("249.99"),
                    "front_bumper_cover");

            addPartIfMissing(partRepository, frontBumper,
                    "Lower grille",
                    "Center lower air intake grille",
                    "DEMO-FB-002",
                    2, 1,
                    new BigDecimal("89.99"),
                    "front_bumper_lower_grille");

            addPartIfMissing(partRepository, frontBumper,
                    "Left air grille",
                    "Left-side air intake grille",
                    "DEMO-FB-003",
                    3, 1,
                    new BigDecimal("49.99"),
                    "front_bumper_left_grille");

            addPartIfMissing(partRepository, frontBumper,
                    "Right air grille",
                    "Right-side air intake grille",
                    "DEMO-FB-004",
                    4, 1,
                    new BigDecimal("49.99"),
                    "front_bumper_right_grille");

            addPartIfMissing(partRepository, frontBumper,
                    "Left bumper bracket",
                    "Left mounting bracket for the front bumper",
                    "DEMO-FB-005",
                    5, 1,
                    new BigDecimal("34.99"),
                    "front_bumper_left_bracket");

            addPartIfMissing(partRepository, frontBumper,
                    "Right bumper bracket",
                    "Right mounting bracket for the front bumper",
                    "DEMO-FB-006",
                    6, 1,
                    new BigDecimal("34.99"),
                    "front_bumper_right_bracket");

            addPartIfMissing(partRepository, frontBumper,
                    "Bumper reinforcement",
                    "Structural reinforcement behind the bumper cover",
                    "DEMO-FB-007",
                    7, 1,
                    new BigDecimal("139.99"),
                    "front_bumper_reinforcement");

            addPartIfMissing(partRepository, frontBumper,
                    "Lower spoiler",
                    "Lower aerodynamic trim beneath the front bumper",
                    "DEMO-FB-008",
                    8, 1,
                    new BigDecimal("69.99"),
                    "front_bumper_lower_spoiler");


            // =================================================
            // ENGINE
            // =================================================

            addPartIfMissing(partRepository, engine,
                    "Engine cover",
                    "Upper protective and decorative engine cover",
                    "DEMO-EN-001",
                    1, 1,
                    new BigDecimal("89.99"),
                    "engine_cover");

            addPartIfMissing(partRepository, engine,
                    "Air filter housing",
                    "Housing containing the engine air filter",
                    "DEMO-EN-002",
                    2, 1,
                    new BigDecimal("119.99"),
                    "engine_air_filter_housing");

            addPartIfMissing(partRepository, engine,
                    "Air intake hose",
                    "Air hose connecting the intake system",
                    "DEMO-EN-003",
                    3, 1,
                    new BigDecimal("54.99"),
                    "engine_air_intake_hose");

            addPartIfMissing(partRepository, engine,
                    "Coolant expansion tank",
                    "Reservoir for the engine cooling system",
                    "DEMO-EN-004",
                    4, 1,
                    new BigDecimal("59.99"),
                    "engine_coolant_tank");

            addPartIfMissing(partRepository, engine,
                    "Oil filler cap",
                    "Cap sealing the engine oil filler opening",
                    "DEMO-EN-005",
                    5, 1,
                    new BigDecimal("19.99"),
                    "engine_oil_filler_cap");

            addPartIfMissing(partRepository, engine,
                    "Ignition coil",
                    "Ignition coil supplying voltage to a spark plug",
                    "DEMO-EN-006",
                    6, 4,
                    new BigDecimal("44.99"),
                    "engine_ignition_coil");

            addPartIfMissing(partRepository, engine,
                    "Battery",
                    "12-volt vehicle starter battery",
                    "DEMO-EN-007",
                    7, 1,
                    new BigDecimal("149.99"),
                    "engine_battery");

            addPartIfMissing(partRepository, engine,
                    "Radiator fan",
                    "Electric fan supporting engine cooling",
                    "DEMO-EN-008",
                    8, 1,
                    new BigDecimal("179.99"),
                    "engine_radiator_fan");


            // =================================================
            // REAR BUMPER
            // =================================================

            addPartIfMissing(partRepository, rearBumper,
                    "Rear bumper cover",
                    "Visible outer cover of the rear bumper",
                    "DEMO-RB-001",
                    1, 1,
                    new BigDecimal("239.99"),
                    "rear_bumper_cover");

            addPartIfMissing(partRepository, rearBumper,
                    "Lower rear valance",
                    "Lower trim section of the rear bumper",
                    "DEMO-RB-002",
                    2, 1,
                    new BigDecimal("99.99"),
                    "rear_bumper_valance");

            addPartIfMissing(partRepository, rearBumper,
                    "Left bumper bracket",
                    "Left mounting bracket for the rear bumper",
                    "DEMO-RB-003",
                    3, 1,
                    new BigDecimal("32.99"),
                    "rear_bumper_left_bracket");

            addPartIfMissing(partRepository, rearBumper,
                    "Right bumper bracket",
                    "Right mounting bracket for the rear bumper",
                    "DEMO-RB-004",
                    4, 1,
                    new BigDecimal("32.99"),
                    "rear_bumper_right_bracket");

            addPartIfMissing(partRepository, rearBumper,
                    "Rear bumper reinforcement",
                    "Structural reinforcement behind the rear bumper",
                    "DEMO-RB-005",
                    5, 1,
                    new BigDecimal("129.99"),
                    "rear_bumper_reinforcement");

            addPartIfMissing(partRepository, rearBumper,
                    "Parking sensor",
                    "Ultrasonic sensor used by the parking assistance system",
                    "DEMO-RB-006",
                    6, 4,
                    new BigDecimal("39.99"),
                    "rear_bumper_parking_sensor");

            addPartIfMissing(partRepository, rearBumper,
                    "Left reflector",
                    "Left rear bumper reflector",
                    "DEMO-RB-007",
                    7, 1,
                    new BigDecimal("24.99"),
                    "rear_bumper_left_reflector");


            // =================================================
            // SIDE MIRROR
            // =================================================

            addPartIfMissing(partRepository, sideMirror,
                    "Mirror housing",
                    "Main exterior housing of the side mirror",
                    "DEMO-SM-001",
                    1, 1,
                    new BigDecimal("109.99"),
                    "side_mirror_housing");

            addPartIfMissing(partRepository, sideMirror,
                    "Mirror glass",
                    "Reflective glass element of the exterior mirror",
                    "DEMO-SM-002",
                    2, 1,
                    new BigDecimal("59.99"),
                    "side_mirror_glass");

            addPartIfMissing(partRepository, sideMirror,
                    "Mirror cap",
                    "Painted or decorative outer mirror cover",
                    "DEMO-SM-003",
                    3, 1,
                    new BigDecimal("49.99"),
                    "side_mirror_cap");

            addPartIfMissing(partRepository, sideMirror,
                    "Mirror adjustment motor",
                    "Electric motor used to adjust mirror position",
                    "DEMO-SM-004",
                    4, 1,
                    new BigDecimal("69.99"),
                    "side_mirror_motor");

            addPartIfMissing(partRepository, sideMirror,
                    "Turn signal indicator",
                    "Integrated LED turn signal in the mirror",
                    "DEMO-SM-005",
                    5, 1,
                    new BigDecimal("39.99"),
                    "side_mirror_indicator");

            addPartIfMissing(partRepository, sideMirror,
                    "Mirror mounting base",
                    "Base attaching the mirror assembly to the door",
                    "DEMO-SM-006",
                    6, 1,
                    new BigDecimal("79.99"),
                    "side_mirror_mounting_base");


            // =================================================
            // DOOR
            // =================================================

            addPartIfMissing(partRepository, door,
                    "Outer door handle",
                    "Exterior handle used to open the door",
                    "DEMO-DR-001",
                    1, 1,
                    new BigDecimal("59.99"),
                    "door_outer_handle");

            addPartIfMissing(partRepository, door,
                    "Door lock",
                    "Mechanical and electronic door locking mechanism",
                    "DEMO-DR-002",
                    2, 1,
                    new BigDecimal("119.99"),
                    "door_lock");

            addPartIfMissing(partRepository, door,
                    "Window regulator",
                    "Mechanism used to raise and lower the door window",
                    "DEMO-DR-003",
                    3, 1,
                    new BigDecimal("109.99"),
                    "door_window_regulator");

            addPartIfMissing(partRepository, door,
                    "Window motor",
                    "Electric motor driving the window regulator",
                    "DEMO-DR-004",
                    4, 1,
                    new BigDecimal("89.99"),
                    "door_window_motor");

            addPartIfMissing(partRepository, door,
                    "Door speaker",
                    "Audio speaker mounted inside the door",
                    "DEMO-DR-005",
                    5, 1,
                    new BigDecimal("69.99"),
                    "door_speaker");

            addPartIfMissing(partRepository, door,
                    "Interior door handle",
                    "Handle used to open the door from inside the vehicle",
                    "DEMO-DR-006",
                    6, 1,
                    new BigDecimal("39.99"),
                    "door_inner_handle");

            addPartIfMissing(partRepository, door,
                    "Door trim panel",
                    "Interior trim panel covering the inside of the door",
                    "DEMO-DR-007",
                    7, 1,
                    new BigDecimal("159.99"),
                    "door_trim_panel");

            addPartIfMissing(partRepository, door,
                    "Door seal",
                    "Rubber weather seal surrounding the door opening",
                    "DEMO-DR-008",
                    8, 1,
                    new BigDecimal("54.99"),
                    "door_seal");
        };
    }


    // =========================================================
    // HELPER
    // =========================================================

    private void addPartIfMissing(
            CarPartRepository partRepository,
            Assembly assembly,
            String name,
            String description,
            String referenceNumber,
            Integer calloutNumber,
            Integer quantity,
            BigDecimal price,
            String imageIdentifier
    ) {

        if (!partRepository.existsByAssemblyAndReferenceNumber(
                assembly,
                referenceNumber
        )) {

            partRepository.save(new CarPart(
                    assembly,
                    name,
                    description,
                    referenceNumber,
                    calloutNumber,
                    quantity,
                    price,
                    imageIdentifier
            ));
        }
    }
}