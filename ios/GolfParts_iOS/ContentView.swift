import SwiftUI
import GoogleSignIn
import GoogleSignInSwift


struct ContentView: View {

    // ============================================================
    // MARK: - Backend / Render Status
    // ============================================================

    @State private var backendStatus = "Starting service…"
    @State private var backendAvailable = false

    private let backendStatusService = BackendStatusService()


    // ============================================================
    // MARK: - Google Authentication
    // ============================================================

    @State private var status = "Ready to sign in"
    @State private var idToken: String?
    @State private var isSignedIn = false


    // ============================================================
    // MARK: - Image Selection
    // ============================================================

    @State private var showCamera = false
    @State private var showPhotoPicker = false
    @State private var showImageSourceOptions = false

    @State private var selectedImage: UIImage?

    @State private var showingImageCrop = false


    // ============================================================
    // MARK: - AI Scan
    // ============================================================

    @State private var scanResult: ScanResult?

    @State private var isScanning = false

    // Friendly error shown when AI analysis fails.
    @State private var scanError: String?

    private let scanAPIService = ScanAPIService()


    // ============================================================
    // MARK: - Assembly Parts
    // ============================================================

    @State private var parts: [CarPart] = []

    @State private var isLoadingParts = false

    @State private var partsError: String?

    @State private var showingAssemblyDiagram = false

    private let partsAPIService = PartsAPIService()


    // ============================================================
    // MARK: - Main User Interface
    // ============================================================

    var body: some View {

        ScrollView {

            VStack(spacing: 24) {

                // ------------------------------------------------
                // App title
                // ------------------------------------------------

                Text("GolfParts")
                    .font(.largeTitle)
                    .bold()


                // ------------------------------------------------
                // Backend status
                // ------------------------------------------------

                HStack(spacing: 8) {

                    Circle()
                        .fill(
                            backendAvailable
                                ? Color.green
                                : Color.orange
                        )
                        .frame(
                            width: 10,
                            height: 10
                        )


                    Text(backendStatus)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }


                // =================================================
                // NOT SIGNED IN
                // =================================================

                if !isSignedIn {

                    GoogleSignInButton {

                        Task {

                            await signIn()
                        }
                    }
                    .frame(height: 50)


                    Text(status)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .textSelection(.enabled)


                // =================================================
                // SIGNED IN
                // =================================================

                } else {

                    Text("Signed in ✓")
                        .font(.headline)


                    // ------------------------------------------------
                    // Selected image
                    // ------------------------------------------------

                    if let image = selectedImage {

                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                    }


                    // =================================================
                    // Gemini analysis
                    // =================================================

                    if isScanning {

                        // ---------------------------------------------
                        // Gemini is currently analyzing the image
                        // ---------------------------------------------

                        VStack(spacing: 12) {

                            ProgressView()
                                .controlSize(.large)


                            Label(
                                "Gemini is analyzing the image…",
                                systemImage: "sparkles"
                            )
                            .font(.headline)


                            Text(
                                "AI is identifying the vehicle assembly. This can take a few seconds."
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        }
                        .padding()


                    } else if let scanError {

                        // ---------------------------------------------
                        // Friendly AI failure state
                        // ---------------------------------------------

                        VStack(spacing: 12) {

                            Image(
                                systemName:
                                    "sparkles"
                            )
                            .font(.largeTitle)


                            Text(
                                "Couldn't analyze the image"
                            )
                            .font(.headline)


                            Text(scanError)
                                .font(.caption)
                                .foregroundStyle(
                                    .secondary
                                )
                                .multilineTextAlignment(
                                    .center
                                )


                            // Retry the SAME cropped image.
                            //
                            // The user does not need to take the
                            // photograph or crop it again.

                            if let image = selectedImage {

                                Button {

                                    Task {

                                        await scan(
                                            image
                                        )
                                    }

                                } label: {

                                    Label(
                                        "Try Again with Gemini",
                                        systemImage:
                                            "arrow.clockwise"
                                    )
                                }
                                .buttonStyle(
                                    .borderedProminent
                                )
                            }
                        }
                        .padding()


                    } else if let result = scanResult {

                        // ---------------------------------------------
                        // Successful Gemini result
                        // ---------------------------------------------

                        VStack(spacing: 10) {

                            Label(
                                "AI Visual Analysis",
                                systemImage:
                                    "sparkles"
                            )
                            .font(.caption)
                            .foregroundStyle(
                                .secondary
                            )


                            Text(
                                "Detected Assembly"
                            )
                            .font(.caption)


                            Text(

                                result
                                    .assemblyCode
                                    .replacingOccurrences(
                                        of: "_",
                                        with: " "
                                    )
                            )
                            .font(.title2)
                            .bold()


                            Text(
                                "Confidence: \(Int(result.confidence * 100))%"
                            )


                            Text(
                                "Identified with Gemini"
                            )
                            .font(.caption)
                            .foregroundStyle(
                                .secondary
                            )


                            if result.assemblyCode
                                != "UNKNOWN" {

                                Button(
                                    "Show Parts"
                                ) {

                                    Task {

                                        await loadParts(
                                            assemblyCode:
                                                result
                                                    .assemblyCode
                                        )
                                    }
                                }
                                .buttonStyle(
                                    .borderedProminent
                                )
                                .disabled(
                                    isLoadingParts
                                )
                            }
                        }
                    }


                    // ------------------------------------------------
                    // Parts loading
                    // ------------------------------------------------

                    if isLoadingParts {

                        ProgressView(
                            "Loading parts…"
                        )
                    }


                    // ------------------------------------------------
                    // Parts API error
                    // ------------------------------------------------

                    if let partsError {

                        Text(partsError)
                            .foregroundStyle(
                                .red
                            )
                            .font(.caption)
                            .multilineTextAlignment(
                                .center
                            )
                    }


                    // =================================================
                    // Scan Golf
                    // =================================================

                    Button(
                        "Scan Golf"
                    ) {

                        parts = []

                        partsError = nil

                        scanResult = nil

                        scanError = nil

                        showingAssemblyDiagram =
                            false


                        showImageSourceOptions =
                            true
                    }
                    .buttonStyle(
                        .borderedProminent
                    )
                    .disabled(
                        isScanning ||
                        !backendAvailable
                    )


                    // ------------------------------------------------
                    // Camera / Photo Library selection
                    // ------------------------------------------------

                    .confirmationDialog(

                        "Choose Image Source",

                        isPresented:
                            $showImageSourceOptions,

                        titleVisibility:
                            .visible

                    ) {

                        Button(
                            "Take Photo"
                        ) {

                            showCamera =
                                true
                        }


                        Button(
                            "Choose from Photos"
                        ) {

                            showPhotoPicker =
                                true
                        }


                        Button(
                            "Cancel",
                            role:
                                .cancel
                        ) {
                        }
                    }


                    // ------------------------------------------------
                    // General app status
                    // ------------------------------------------------

                    Text(status)
                        .font(.caption)
                        .multilineTextAlignment(
                            .center
                        )
                        .textSelection(
                            .enabled
                        )
                }
            }
            .padding()
        }


        // ============================================================
        // MARK: - Photo Library
        // ============================================================

        .sheet(
            isPresented:
                $showPhotoPicker
        ) {

            PhotoPicker { image in

                prepareNewImage(
                    image
                )

                showingImageCrop =
                    true
            }
        }


        // ============================================================
        // MARK: - Camera
        // ============================================================

        .sheet(
            isPresented:
                $showCamera
        ) {

            CameraPicker { image in

                prepareNewImage(
                    image
                )

                showingImageCrop =
                    true
            }
        }


        // ============================================================
        // MARK: - Crop / Zoom
        // ============================================================

        .sheet(
            isPresented:
                $showingImageCrop
        ) {

            if let image =
                selectedImage {

                ImageCropView(

                    image:
                        image,

                    onCrop: {
                        croppedImage in


                        // Close crop screen.

                        showingImageCrop =
                            false


                        // Store exactly the area that
                        // will be sent to Gemini.

                        selectedImage =
                            croppedImage


                        // Analyze selected region.

                        Task {

                            await scan(
                                croppedImage
                            )
                        }
                    },

                    onCancel: {

                        showingImageCrop =
                            false
                    }
                )
            }
        }


        // ============================================================
        // MARK: - Visual Assembly Diagram
        // ============================================================

        .sheet(
            isPresented:
                $showingAssemblyDiagram
        ) {

            if let result =
                scanResult {

                AssemblyDiagramView(

                    assemblyCode:
                        result
                            .assemblyCode,

                    parts:
                        parts
                )
            }
        }


        // ============================================================
        // MARK: - Google Sign-In Callback
        // ============================================================

        .onOpenURL { url in

            GIDSignIn
                .sharedInstance
                .handle(
                    url
                )
        }


        // ============================================================
        // MARK: - Wake Render
        // ============================================================

        .task {

            await checkBackend()
        }
    }


    // ================================================================
    // MARK: - Prepare New Image
    // ================================================================

    @MainActor
    private func prepareNewImage(
        _ image: UIImage
    ) {

        selectedImage =
            image


        scanResult =
            nil


        scanError =
            nil


        parts =
            []


        partsError =
            nil


        showingAssemblyDiagram =
            false
    }


    // ================================================================
    // MARK: - Backend Health Check
    // ================================================================

    @MainActor
    private func checkBackend() async {

        backendAvailable =
            false


        backendStatus =
            "Starting service…"


        let available =
            await backendStatusService
                .waitUntilAvailable()


        backendAvailable =
            available


        if available {

            backendStatus =
                "Service online ✓"

        } else {

            backendStatus =
                "Service unavailable"
        }
    }


    // ================================================================
    // MARK: - Scan Image with Gemini
    // ================================================================

    @MainActor
    private func scan(
        _ image: UIImage
    ) async {

        guard let token =
                idToken else {

            status =
                "No Google ID token available."

            return
        }


        guard let imageData =
                image.jpegData(
                    compressionQuality:
                        0.85
                ) else {

            status =
                "Could not convert image to JPEG."

            return
        }


        do {

            // Clear any previous AI error.

            scanError =
                nil


            // Clear old result so the progress
            // screen is displayed cleanly.

            scanResult =
                nil


            isScanning =
                true


            status =
                "Gemini analysis in progress…"


            let result =
                try await scanAPIService
                    .scanImage(

                        imageData:
                            imageData,

                        mimeType:
                            "image/jpeg",

                        idToken:
                            token
                    )


            scanResult =
                result


            status =
                "Analysis complete"


        } catch {

            // --------------------------------------------------------
            // User-friendly AI error
            // --------------------------------------------------------
            //
            // For now we use this friendly message for scan failures.
            //
            // In the next backend improvement we can distinguish:
            //
            // Gemini/provider unavailable
            //            vs
            // genuine Spring Boot error.
            //

            scanError =
                """
                We're using the Gemini free service, which can occasionally be busy or respond slowly.

                Please try again.
                """


            status =
                "AI analysis unsuccessful"
        }


        isScanning =
            false
    }


    // ================================================================
    // MARK: - Load Assembly Parts
    // ================================================================

    @MainActor
    private func loadParts(
        assemblyCode: String
    ) async {

        guard let token =
                idToken else {

            partsError =
                "No Google ID token available."

            return
        }


        do {

            isLoadingParts =
                true


            partsError =
                nil


            let loadedParts =
                try await partsAPIService
                    .getParts(

                        assemblyCode:
                            assemblyCode,

                        idToken:
                            token
                    )


            // Store real parts returned by PostgreSQL.

            parts =
                loadedParts


            // Open exploded visual assembly screen.

            showingAssemblyDiagram =
                true


        } catch {

            partsError =
                """
                Could not load parts:
                \(error.localizedDescription)
                """
        }


        isLoadingParts =
            false
    }


    // ================================================================
    // MARK: - Google Sign-In
    // ================================================================

    @MainActor
    private func signIn() async {

        guard let scene =
                UIApplication
                    .shared
                    .connectedScenes
                    .compactMap({

                        $0 as? UIWindowScene
                    })
                    .first(where: {

                        $0.activationState
                            == .foregroundActive
                    }),

              let presenter =
                scene
                    .windows
                    .first(where: {

                        $0.isKeyWindow
                    })?
                    .rootViewController else {

            status =
                "Could not open the Google sign-in screen."

            return
        }


        do {

            status =
                "Signing in with Google…"


            let result =
                try await GIDSignIn
                    .sharedInstance
                    .signIn(

                        withPresenting:
                            presenter
                    )


            guard let token =
                    result
                        .user
                        .idToken?
                        .tokenString else {

                status =
                    "Google sign-in worked, but no ID token was returned."

                return
            }


            idToken =
                token


            status =
                "Checking API access…"


            guard let url =
                    URL(
                        string:
                            "https://api.divijwadhawan.com/me"
                    ) else {

                status =
                    "Invalid API URL."

                return
            }


            var request =
                URLRequest(
                    url:
                        url
                )


            request.httpMethod =
                "GET"


            request.setValue(

                "Bearer \(token)",

                forHTTPHeaderField:
                    "Authorization"
            )


            let (
                data,
                response
            ) =
                try await URLSession
                    .shared
                    .data(
                        for:
                            request
                    )


            let code =
                (response
                    as? HTTPURLResponse)?
                    .statusCode
                ?? 0


            let responseBody =
                String(

                    data:
                        data,

                    encoding:
                        .utf8

                ) ?? ""


            // Never print the Google ID token.

            print(
                "API /me HTTP:",
                code
            )


            print(
                "API /me response:",
                responseBody
            )


            if code == 200 {

                isSignedIn =
                    true


                status =
                    "API connection successful"


            } else {

                status =
                    """
                    API access failed
                    HTTP \(code)

                    \(responseBody)
                    """
            }


        } catch {

            status =
                """
                Sign-in or network error:

                \(error.localizedDescription)
                """
        }
    }
}
