//
//  AssemblyDiagramView.swift
//  GolfParts_iOS
//

import SwiftUI


struct AssemblyDiagramView: View {

    // ============================================================
    // MARK: - Input
    // ============================================================

    /// Assembly identified by Gemini.
    ///
    /// Supported:
    /// FRONT_BUMPER
    /// REAR_BUMPER
    /// ENGINE
    /// SIDE_MIRROR
    /// DOOR
    let assemblyCode: String


    /// Parts returned by Spring Boot / PostgreSQL.
    let parts: [CarPart]


    // ============================================================
    // MARK: - Selected Part
    // ============================================================

    @State private var selectedPart: CarPart?


    // ============================================================
    // MARK: - Body
    // ============================================================

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 22) {

                    // ------------------------------------------------
                    // Assembly title
                    // ------------------------------------------------

                    Text(assemblyTitle)
                        .font(.title2)
                        .bold()


                    Text(
                        "Tap a numbered callout to inspect the part."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)


                    // =================================================
                    // Exploded Assembly Diagram
                    // =================================================

                    assemblyDiagram


                    // =================================================
                    // Selected Part
                    // =================================================

                    if let selectedPart {

                        selectedPartCard(
                            selectedPart
                        )
                        .transition(
                            .opacity
                                .combined(
                                    with: .move(
                                        edge: .top
                                    )
                                )
                        )
                    }


                    // =================================================
                    // All Parts
                    // =================================================

                    partsList
                }
                .padding()
            }

            .navigationTitle(
                "Assembly"
            )

            .navigationBarTitleDisplayMode(
                .inline
            )

            .animation(
                .easeInOut(
                    duration: 0.2
                ),
                value: selectedPart?.id
            )
        }
    }


    // ================================================================
    // MARK: - Assembly Title
    // ================================================================

    private var assemblyTitle: String {

        switch assemblyCode {

        case "FRONT_BUMPER":
            return "Front Bumper"

        case "REAR_BUMPER":
            return "Rear Bumper"

        case "ENGINE":
            return "Engine"

        case "SIDE_MIRROR":
            return "Side Mirror"

        case "DOOR":
            return "Door"

        default:

            return assemblyCode
                .replacingOccurrences(
                    of: "_",
                    with: " "
                )
        }
    }


    // ================================================================
    // MARK: - Diagram Image
    // ================================================================

    private var diagramImageName: String? {

        switch assemblyCode {

        case "FRONT_BUMPER":
            return "front_bumper_diagram"

        case "REAR_BUMPER":
            return "rear_bumper_diagram"

        case "ENGINE":
            return "engine_diagram"

        case "SIDE_MIRROR":
            return "side_mirror_diagram"

        case "DOOR":
            return "door_diagram"

        default:
            return nil
        }
    }


    // ================================================================
    // MARK: - Callout Positions
    // ================================================================
    //
    // Coordinates are normalized:
    //
    // x = 0.0 → left
    // x = 1.0 → right
    //
    // y = 0.0 → top
    // y = 1.0 → bottom
    //
    // This makes the callouts work regardless of iPhone screen size.
    //

    private var calloutPositions:
        [Int: CGPoint] {

        switch assemblyCode {


        // ============================================================
        // FRONT BUMPER
        // ============================================================

        case "FRONT_BUMPER":

            return [

                1: CGPoint(
                    x: 0.27,
                    y: 0.17
                ),

                2: CGPoint(
                    x: 0.62,
                    y: 0.23
                ),

                3: CGPoint(
                    x: 0.64,
                    y: 0.47
                ),

                4: CGPoint(
                    x: 0.63,
                    y: 0.64
                ),

                5: CGPoint(
                    x: 0.32,
                    y: 0.70
                ),

                6: CGPoint(
                    x: 0.62,
                    y: 0.78
                ),

                7: CGPoint(
                    x: 0.12,
                    y: 0.84
                ),

                8: CGPoint(
                    x: 0.43,
                    y: 0.93
                )
            ]


        // ============================================================
        // REAR BUMPER
        // ============================================================

        case "REAR_BUMPER":

            return [

                1: CGPoint(
                    x: 0.22,
                    y: 0.20
                ),

                2: CGPoint(
                    x: 0.50,
                    y: 0.27
                ),

                3: CGPoint(
                    x: 0.18,
                    y: 0.48
                ),

                4: CGPoint(
                    x: 0.82,
                    y: 0.48
                ),

                5: CGPoint(
                    x: 0.50,
                    y: 0.58
                ),

                6: CGPoint(
                    x: 0.70,
                    y: 0.73
                ),

                7: CGPoint(
                    x: 0.28,
                    y: 0.82
                )
            ]


        // ============================================================
        // ENGINE
        // ============================================================

        case "ENGINE":

            return [

                1: CGPoint(
                    x: 0.50,
                    y: 0.18
                ),

                2: CGPoint(
                    x: 0.22,
                    y: 0.30
                ),

                3: CGPoint(
                    x: 0.72,
                    y: 0.31
                ),

                4: CGPoint(
                    x: 0.17,
                    y: 0.53
                ),

                5: CGPoint(
                    x: 0.50,
                    y: 0.48
                ),

                6: CGPoint(
                    x: 0.65,
                    y: 0.55
                ),

                7: CGPoint(
                    x: 0.82,
                    y: 0.63
                ),

                8: CGPoint(
                    x: 0.50,
                    y: 0.82
                )
            ]


        // ============================================================
        // SIDE MIRROR
        // ============================================================

        case "SIDE_MIRROR":

            return [

                1: CGPoint(
                    x: 0.35,
                    y: 0.22
                ),

                2: CGPoint(
                    x: 0.57,
                    y: 0.27
                ),

                3: CGPoint(
                    x: 0.42,
                    y: 0.42
                ),

                4: CGPoint(
                    x: 0.55,
                    y: 0.57
                ),

                5: CGPoint(
                    x: 0.42,
                    y: 0.72
                ),

                6: CGPoint(
                    x: 0.67,
                    y: 0.82
                )
            ]


        // ============================================================
        // DOOR
        // ============================================================

        case "DOOR":

            return [

                1: CGPoint(
                    x: 0.73,
                    y: 0.20
                ),

                2: CGPoint(
                    x: 0.78,
                    y: 0.38
                ),

                3: CGPoint(
                    x: 0.43,
                    y: 0.38
                ),

                4: CGPoint(
                    x: 0.55,
                    y: 0.53
                ),

                5: CGPoint(
                    x: 0.30,
                    y: 0.65
                ),

                6: CGPoint(
                    x: 0.68,
                    y: 0.64
                ),

                7: CGPoint(
                    x: 0.42,
                    y: 0.78
                ),

                8: CGPoint(
                    x: 0.82,
                    y: 0.84
                )
            ]


        default:

            return [:]
        }
    }


    // ================================================================
    // MARK: - Assembly Diagram
    // ================================================================

    @ViewBuilder
    private var assemblyDiagram: some View {

        if let imageName =
            diagramImageName {

            GeometryReader { geometry in

                let width =
                    geometry.size.width


                let height =
                    width * 0.67


                ZStack {

                    // ------------------------------------------------
                    // Exploded assembly image
                    // ------------------------------------------------

                    Image(
                        imageName
                    )
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: width,
                        height: height
                    )


                    // ------------------------------------------------
                    // Interactive callouts
                    // ------------------------------------------------

                    ForEach(
                        calloutPositions
                            .keys
                            .sorted(),
                        id: \.self
                    ) { number in

                        if let point =
                            calloutPositions[
                                number
                            ] {

                            calloutButton(

                                number,

                                x:
                                    point.x,

                                y:
                                    point.y,

                                width:
                                    width,

                                height:
                                    height
                            )
                        }
                    }
                }
            }

            .aspectRatio(
                3 / 2,
                contentMode:
                    .fit
            )

            .clipShape(

                RoundedRectangle(
                    cornerRadius: 16
                )
            )


        } else {

            ContentUnavailableView(

                "Diagram not available",

                systemImage:
                    "car",

                description:
                    Text(
                        "This assembly is not supported yet."
                    )
            )
        }
    }


    // ================================================================
    // MARK: - Callout Button
    // ================================================================

    private func calloutButton(
        _ number: Int,
        x: CGFloat,
        y: CGFloat,
        width: CGFloat,
        height: CGFloat
    ) -> some View {

        Button {

            // --------------------------------------------------------
            // Find the actual backend part corresponding to
            // this callout number.
            // --------------------------------------------------------

            selectedPart =
                parts.first {

                    $0.calloutNumber
                        == number
                }

        } label: {

            ZStack {

                Circle()
                    .fill(

                        selectedPart?
                            .calloutNumber
                            == number

                        ? Color.orange

                        : Color.blue
                    )


                Text(
                    "\(number)"
                )
                .font(
                    .caption
                )
                .bold()
                .foregroundStyle(
                    .white
                )
            }

            .frame(
                width: 32,
                height: 32
            )

            .shadow(
                radius: 2
            )
        }

        .position(

            x:
                width * x,

            y:
                height * y
        )
    }


    // ================================================================
    // MARK: - Selected Part Card
    // ================================================================

    @ViewBuilder
    private func selectedPartCard(
        _ part: CarPart
    ) -> some View {

        VStack(
            alignment:
                .leading,
            spacing:
                14
        ) {

            // --------------------------------------------------------
            // Header
            // --------------------------------------------------------

            HStack {

                Text(
                    "Part \(part.calloutNumber)"
                )
                .font(.caption)
                .fontWeight(
                    .semibold
                )
                .foregroundStyle(
                    .secondary
                )


                Spacer()


                Text(
                    String(
                        format:
                            "€%.2f",
                        part.price
                    )
                )
                .font(.headline)
            }


            // ========================================================
            // Individual Part Image
            // ========================================================
            //
            // imageIdentifier comes from PostgreSQL.
            //
            // Example:
            //
            // engine_battery
            //
            // SwiftUI then looks for an asset with exactly
            // the same name.
            //

            if let imageIdentifier =
                part.imageIdentifier,
               !imageIdentifier.isEmpty {

                Image(
                    imageIdentifier
                )
                .resizable()
                .scaledToFit()
                .frame(
                    maxWidth:
                        .infinity
                )
                .frame(
                    height:
                        210
                )
            }


            // --------------------------------------------------------
            // Part name
            // --------------------------------------------------------

            Text(
                part.name
            )
            .font(.title3)
            .bold()


            // --------------------------------------------------------
            // Reference
            // --------------------------------------------------------

            HStack {

                Text(
                    "Reference"
                )
                .foregroundStyle(
                    .secondary
                )


                Spacer()


                Text(
                    part.referenceNumber
                )
                .fontDesign(
                    .monospaced
                )
            }
            .font(.subheadline)


            Divider()


            // --------------------------------------------------------
            // Description
            // --------------------------------------------------------

            if let description =
                part.description,
               !description.isEmpty {

                Text(
                    description
                )
                .font(.subheadline)
                .foregroundStyle(
                    .secondary
                )
            }


            // --------------------------------------------------------
            // Quantity
            // --------------------------------------------------------

            HStack {

                Text(
                    "Quantity"
                )
                .foregroundStyle(
                    .secondary
                )


                Spacer()


                Text(
                    "\(part.quantity)"
                )
            }
            .font(.subheadline)


            // --------------------------------------------------------
            // Price
            // --------------------------------------------------------

            HStack {

                Text(
                    "Demo price"
                )
                .foregroundStyle(
                    .secondary
                )


                Spacer()


                Text(
                    String(
                        format:
                            "€%.2f",
                        part.price
                    )
                )
                .fontWeight(
                    .semibold
                )
            }
            .font(.subheadline)
        }

        .padding()

        .background(

            RoundedRectangle(
                cornerRadius: 16
            )

            .fill(

                Color(
                    uiColor:
                        .secondarySystemBackground
                )
            )
        )

        .overlay(

            RoundedRectangle(
                cornerRadius: 16
            )

            .stroke(

                Color
                    .secondary
                    .opacity(
                        0.15
                    )
            )
        )
    }


    // ================================================================
    // MARK: - All Parts List
    // ================================================================

    private var partsList: some View {

        VStack(
            alignment:
                .leading,
            spacing:
                12
        ) {

            Text(
                "All Parts"
            )
            .font(.headline)


            ForEach(
                parts.sorted {

                    $0.calloutNumber
                        < $1.calloutNumber
                }
            ) { part in

                Button {

                    selectedPart =
                        part

                } label: {

                    HStack(
                        spacing:
                            12
                    ) {

                        // --------------------------------------------
                        // Callout number
                        // --------------------------------------------

                        ZStack {

                            Circle()
                                .fill(

                                    selectedPart?
                                        .id
                                        == part.id

                                    ? Color.orange

                                    : Color.blue
                                )


                            Text(
                                "\(part.calloutNumber)"
                            )
                            .font(.caption)
                            .bold()
                            .foregroundStyle(
                                .white
                            )
                        }

                        .frame(
                            width: 30,
                            height: 30
                        )


                        // --------------------------------------------
                        // Name / Reference
                        // --------------------------------------------

                        VStack(
                            alignment:
                                .leading,
                            spacing:
                                3
                        ) {

                            Text(
                                part.name
                            )
                            .fontWeight(
                                .medium
                            )


                            Text(
                                part.referenceNumber
                            )
                            .font(.caption)
                            .foregroundStyle(
                                .secondary
                            )
                        }


                        Spacer()


                        // --------------------------------------------
                        // Price
                        // --------------------------------------------

                        Text(
                            String(
                                format:
                                    "€%.2f",
                                part.price
                            )
                        )
                        .fontWeight(
                            .semibold
                        )


                        Image(
                            systemName:
                                "chevron.right"
                        )
                        .font(.caption)
                        .foregroundStyle(
                            .secondary
                        )
                    }

                    .padding(
                        .vertical,
                        6
                    )

                    .contentShape(
                        Rectangle()
                    )
                }

                .buttonStyle(
                    .plain
                )


                if part.id
                    != parts.last?.id {

                    Divider()
                }
            }
        }

        .padding()

        .background(

            RoundedRectangle(
                cornerRadius: 16
            )

            .fill(

                Color(
                    uiColor:
                        .secondarySystemBackground
                )
            )
        )
    }
}
