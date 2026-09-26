import SwiftUI
import GoogleSignIn
import GoogleSignInSwift


struct ContentView: View {

    // ============================================================
    // MARK: - Backend / Render Status
    // ============================================================
    //
    // Render's free web service can go to sleep when it has not
    // received traffic for some time.
    //
    // When this view opens, we call our /health endpoint.
    // This:
    //
    // 1. Wakes Render as early as possible.
    // 2. Tells the user whether the backend is ready.
    //

    @State private var backendStatus = "Starting service…"
    @State private var backendAvailable = false

    private let backendStatusService = BackendStatusService()


    // ============================================================
    // MARK: - Google Authentication
    // ============================================================
    //
    // idToken:
    // Google gives us an ID token after successful login.
    // We send this token to Spring Boot in the Authorization header.
    //
    // isSignedIn:
    // Controls whether we show the Google login screen or the
    // actual GolfParts application.
    //

    @State private var status = "Ready to sign in"
    @State private var idToken: String?
    @State private var isSignedIn = false


    // ============================================================
    // MARK: - Image Selection
    // ============================================================
    //
    // The user can either:
    //
    // 1. Take a new picture with the iPhone camera.
    // 2. Select an existing image from the photo library.
    //
    // After an image is selected, we DO NOT immediately send it
    // to Gemini anymore.
    //
    // Instead:
    //
    // Image
    //   ↓
    // Crop / Zoom
    //   ↓
    // Cropped UIImage
    //   ↓
    // Gemini
    //

    @State private var showCamera = false
    @State private var showPhotoPicker = false
    @State private var showImageSourceOptions = false

    // Original image selected/taken by the user.
    // After cropping, this becomes the cropped image.
    @State private var selectedImage: UIImage?

    // Controls whether ImageCropView is visible.
    @State private var showingImageCrop = false


    // ============================================================
    // MARK: - AI Scan
    // ============================================================
    //
    // scanResult contains the result returned by Spring Boot.
    //
    // Example:
    //
    // assemblyCode = "FRONT_BUMPER"
    // confidence   = 0.95
    // boundingBox  = ...
    //

    @State private var scanResult: ScanResult?
    @State private var isScanning = false

    private let scanAPIService = ScanAPIService()


    // ============================================================
    // MARK: - Assembly Parts
    // ============================================================
    //
    // After Gemini detects an assembly, the user can press
    // "Show Parts".
    //
    // We then request:
    //
    // GET /assemblies/{assemblyCode}/parts
    //

    @State private var parts: [CarPart] = []
    @State private var isLoadingParts = false
    @State private var partsError: String?

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
                    // Selected vehicle image
                    // ------------------------------------------------
                    //
                    // Before cropping:
                    // selectedImage contains the original photograph.
                    //
                    // After "Analyze Selection":
                    // selectedImage contains the actual cropped image
                    // that was sent to Gemini.
                    //

                    if let image = selectedImage {

                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                    }


                    // ------------------------------------------------
                    // AI analysis state
                    // ------------------------------------------------

                    if isScanning {

                        ProgressView(
                            "Analyzing Golf…"
                        )

                    } else if let result = scanResult {

                        // --------------------------------------------
                        // AI result
                        // --------------------------------------------

                        VStack(spacing: 10) {

                            Text("Detected Assembly")
                                .font(.caption)


                            // Convert:
                            //
                            // FRONT_BUMPER
                            //
                            // into:
                            //
                            // FRONT BUMPER

                            Text(
                                result.assemblyCode
                                    .replacingOccurrences(
                                        of: "_",
                                        with: " "
                                    )
                            )
                            .font(.title2)
                            .bold()


                            // Gemini returns confidence as 0...1.
                            //
                            // Example:
                            //
                            // 0.95 -> 95%

                            Text(
                                "Confidence: \(Int(result.confidence * 100))%"
                            )


                            // UNKNOWN means Gemini could not reliably
                            // identify one of our supported assemblies.

                            if result.assemblyCode != "UNKNOWN" {

                                Button("Show Parts") {

                                    Task {

                                        await loadParts(
                                            assemblyCode:
                                                result.assemblyCode
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
                    // Parts loading indicator
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
                            .foregroundStyle(.red)
                            .font(.caption)
                            .multilineTextAlignment(
                                .center
                            )
                    }


                    // ------------------------------------------------
                    // Assembly Parts List
                    // ------------------------------------------------
                    //
                    // These parts come from PostgreSQL through our
                    // Spring Boot catalog API.
                    //

                    if !parts.isEmpty {

                        Divider()

                        Text("Assembly Parts")
                            .font(.title2)
                            .bold()

                        VStack(spacing: 12) {

                            ForEach(parts) { part in

                                HStack(
                                    alignment: .top,
                                    spacing: 12
                                ) {

                                    // Part callout number

                                    Text(
                                        "\(part.calloutNumber)"
                                    )
                                    .font(.headline)
                                    .frame(
                                        width: 32,
                                        height: 32
                                    )
                                    .background(
                                        Color.gray
                                            .opacity(0.15)
                                    )
                                    .clipShape(
                                        Circle()
                                    )


                                    // Part information

                                    VStack(
                                        alignment: .leading,
                                        spacing: 4
                                    ) {

                                        Text(part.name)
                                            .font(.headline)


                                        // Demo/reference number

                                        Text(
                                            part.referenceNumber
                                        )
                                        .font(.caption)
                                        .foregroundStyle(
                                            .secondary
                                        )


                                        // Optional description

                                        if let description =
                                                part.description,
                                           !description.isEmpty {

                                            Text(description)
                                                .font(
                                                    .caption
                                                )
                                        }


                                        // Demo price

                                        Text(
                                            "€\(part.price, specifier: "%.2f")"
                                        )
                                        .font(.subheadline)
                                        .bold()
                                    }

                                    Spacer()
                                }
                                .padding()
                                .background(
                                    Color.gray
                                        .opacity(0.08)
                                )
                                .cornerRadius(12)
                            }
                        }
                    }


                    // ------------------------------------------------
                    // Scan Golf Button
                    // ------------------------------------------------
                    //
                    // Disabled while:
                    //
                    // 1. Gemini is already analyzing something.
                    // 2. Render backend is not ready yet.
                    //

                    Button("Scan Golf") {

                        // Clear results from previous scan.

                        parts = []
                        partsError = nil
                        scanResult = nil

                        // Ask user whether they want camera
                        // or photo library.

                        showImageSourceOptions = true
                    }
                    .buttonStyle(
                        .borderedProminent
                    )
                    .disabled(
                        isScanning ||
                        !backendAvailable
                    )


                    // ------------------------------------------------
                    // Camera / Photo Library choice
                    // ------------------------------------------------

                    .confirmationDialog(
                        "Choose Image Source",
                        isPresented:
                            $showImageSourceOptions,
                        titleVisibility: .visible
                    ) {

                        Button("Take Photo") {

                            showCamera = true
                        }

                        Button(
                            "Choose from Photos"
                        ) {

                            showPhotoPicker = true
                        }

                        Button(
                            "Cancel",
                            role: .cancel
                        ) {
                        }
                    }


                    // ------------------------------------------------
                    // General application status
                    // ------------------------------------------------

                    Text(status)
                        .font(.caption)
                        .multilineTextAlignment(
                            .center
                        )
                        .textSelection(.enabled)
                }
            }
            .padding()
        }


        // ============================================================
        // MARK: - Photo Library Sheet
        // ============================================================
        //
        // Opens the iPhone photo library.
        //
        // IMPORTANT:
        // We no longer call scan(image) here.
        //
        // The image is first sent to ImageCropView.
        //

        .sheet(
            isPresented: $showPhotoPicker
        ) {

            PhotoPicker { image in

                prepareNewImage(image)

                // Open crop/zoom screen.
                showingImageCrop = true
            }
        }


        // ============================================================
        // MARK: - Camera Sheet
        // ============================================================
        //
        // Opens the iPhone camera.
        //
        // NSCameraUsageDescription must exist in Info.plist.
        //
        // Again, we do not analyze immediately.
        //

        .sheet(
            isPresented: $showCamera
        ) {

            CameraPicker { image in

                prepareNewImage(image)

                // Open crop/zoom screen.
                showingImageCrop = true
            }
        }


        // ============================================================
        // MARK: - Image Crop / Zoom Sheet
        // ============================================================
        //
        // This is the new step in our workflow.
        //
        // Original photograph
        //       ↓
        // ImageCropView
        //       ↓
        // User zooms + drags
        //       ↓
        // User presses "Analyze Selection"
        //       ↓
        // Cropped UIImage
        //       ↓
        // scan()
        //

        .sheet(
            isPresented: $showingImageCrop
        ) {

            if let image = selectedImage {

                ImageCropView(
                    image: image,

                    onCrop: { croppedImage in

                        // Close crop screen.
                        showingImageCrop = false

                        // Store the actual cropped image.
                        //
                        // This means the image displayed on the main
                        // screen is exactly what we sent to Gemini.
                        selectedImage = croppedImage

                        // Analyze ONLY the selected crop.
                        Task {
                            await scan(croppedImage)
                        }
                    },

                    onCancel: {

                        // User decided not to analyze this image.
                        showingImageCrop = false
                    }
                )
            }
        }


        // ============================================================
        // MARK: - Google Sign-In Callback
        // ============================================================

        .onOpenURL { url in

            GIDSignIn.sharedInstance
                .handle(url)
        }


        // ============================================================
        // MARK: - Wake Render When App Opens
        // ============================================================
        //
        // SwiftUI runs this task when ContentView appears.
        //
        // This means Render begins waking BEFORE the user tries
        // to scan a vehicle.
        //

        .task {

            await checkBackend()
        }
    }


    // ================================================================
    // MARK: - Prepare New Image
    // ================================================================
    //
    // Whenever the user selects/takes another picture, clear the
    // previous AI result and parts.
    //

    @MainActor
    private func prepareNewImage(
        _ image: UIImage
    ) {

        selectedImage = image

        scanResult = nil

        parts = []

        partsError = nil
    }


    // ================================================================
    // MARK: - Backend Health Check
    // ================================================================
    //
    // BackendStatusService repeatedly calls:
    //
    // https://api.divijwadhawan.com/health
    //
    // If Render is sleeping, this first request wakes it.
    //
    // When Spring Boot responds with HTTP 200, the service is ready.
    //

    @MainActor
    private func checkBackend() async {

        backendAvailable = false

        backendStatus =
            "Starting service…"

        let available =
            await backendStatusService
                .waitUntilAvailable()

        backendAvailable = available

        if available {

            backendStatus =
                "Service online ✓"

        } else {

            backendStatus =
                "Service unavailable"
        }
    }


    // ================================================================
    // MARK: - Scan Image
    // ================================================================
    //
    // IMPORTANT:
    //
    // The UIImage arriving here is now the CROPPED image produced
    // by ImageCropView rather than the original whole-car image.
    //
    // Flow:
    //
    // Cropped UIImage
    //       ↓
    // JPEG
    //       ↓
    // POST /scan
    //       ↓
    // Spring Boot
    //       ↓
    // Gemini
    //       ↓
    // ScanResult
    //

    @MainActor
    private func scan(
        _ image: UIImage
    ) async {

        // We need the Google ID token so Spring Security knows
        // which user is making the request.

        guard let token = idToken else {

            status =
                "No Google ID token available."

            return
        }


        // Convert UIImage into JPEG data before uploading.

        guard let imageData =
                image.jpegData(
                    compressionQuality: 0.85
                ) else {

            status =
                "Could not convert image to JPEG."

            return
        }


        do {

            isScanning = true

            status =
                "Analyzing image…"


            // Send image to our Spring Boot API.

            let result =
                try await scanAPIService
                    .scanImage(
                        imageData: imageData,
                        mimeType: "image/jpeg",
                        idToken: token
                    )


            // Save result into SwiftUI state.
            // This automatically updates the screen.

            scanResult = result

            status =
                "Analysis complete"

        } catch {

            status =
                "Scan failed:\n\(error.localizedDescription)"
        }


        isScanning = false
    }


    // ================================================================
    // MARK: - Load Assembly Parts
    // ================================================================
    //
    // Example:
    //
    // assemblyCode = FRONT_BUMPER
    //
    // Request:
    //
    // GET /assemblies/FRONT_BUMPER/parts
    //
    // Response:
    //
    // [CarPart]
    //

    @MainActor
    private func loadParts(
        assemblyCode: String
    ) async {

        guard let token = idToken else {

            partsError =
                "No Google ID token available."

            return
        }


        do {

            isLoadingParts = true

            partsError = nil


            let loadedParts =
                try await partsAPIService
                    .getParts(
                        assemblyCode:
                            assemblyCode,
                        idToken: token
                    )


            // Updating this state automatically redraws
            // the parts list.

            parts = loadedParts

        } catch {

            partsError =
                "Could not load parts:\n\(error.localizedDescription)"
        }


        isLoadingParts = false
    }


    // ================================================================
    // MARK: - Google Sign-In
    // ================================================================
    //
    // Flow:
    //
    // Google login
    //      ↓
    // Google ID Token
    //      ↓
    // GET /me
    //      ↓
    // Spring Security validates Google token
    //      ↓
    // User allowed into app
    //

    @MainActor
    private func signIn() async {

        // Find the currently active iPhone window.
        //
        // Google Sign-In needs a UIViewController from which
        // it can present Google's login screen.

        guard let scene =
                UIApplication.shared
                    .connectedScenes
                    .compactMap({
                        $0 as? UIWindowScene
                    })
                    .first(where: {

                        $0.activationState
                            == .foregroundActive
                    }),

              let presenter =
                scene.windows
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


            // Open Google's authentication screen.

            let result =
                try await GIDSignIn
                    .sharedInstance
                    .signIn(
                        withPresenting:
                            presenter
                    )


            // Retrieve Google's ID token.

            guard let token =
                    result.user
                        .idToken?
                        .tokenString else {

                status =
                    "Google sign-in worked, but no ID token was returned."

                return
            }


            // Keep token in memory so subsequent API calls can use it.

            idToken = token


            // Verify that our backend accepts this Google user.

            status =
                "Checking API access…"


            guard let url = URL(
                string:
                    "https://api.divijwadhawan.com/me"
            ) else {

                status =
                    "Invalid API URL."

                return
            }


            var request =
                URLRequest(url: url)

            request.httpMethod =
                "GET"


            // Spring Security expects:
            //
            // Authorization: Bearer <Google-ID-token>

            request.setValue(
                "Bearer \(token)",
                forHTTPHeaderField:
                    "Authorization"
            )


            let (data, response) =
                try await URLSession.shared
                    .data(
                        for: request
                    )


            let code =
                (response as? HTTPURLResponse)?
                    .statusCode ?? 0


            let responseBody =
                String(
                    data: data,
                    encoding: .utf8
                ) ?? ""


            // Useful during development.
            //
            // We intentionally do NOT print the Google token.

            print(
                "API /me HTTP:",
                code
            )

            print(
                "API /me response:",
                responseBody
            )


            // HTTP 200 means authentication succeeded.

            if code == 200 {

                isSignedIn = true

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
