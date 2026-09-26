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

    @State private var currentGoogleSub: String?

    private let adminGoogleSub =
        "106707840647310647835"

    private var isAdmin: Bool {
        currentGoogleSub == adminGoogleSub
    }


    // ============================================================
    // MARK: - Application Access
    // ============================================================

    enum AppAccessState {

        case checking
        case notRequested
        case pending
        case approved
        case rejected
    }


    @State private var accessState:
        AppAccessState = .checking

    @State private var accessError: String?

    @State private var isRequestingAccess =
        false

    private let accessAPIService =
        AccessAPIService()


    // ============================================================
    // MARK: - Admin
    // ============================================================

    @State private var showingAdmin =
        false


    // ============================================================
    // MARK: - Image Selection
    // ============================================================

    @State private var showCamera =
        false

    @State private var showPhotoPicker =
        false

    @State private var showImageSourceOptions =
        false

    @State private var selectedImage:
        UIImage?

    @State private var showingImageCrop =
        false


    // ============================================================
    // MARK: - AI Scan
    // ============================================================

    @State private var scanResult:
        ScanResult?

    @State private var isScanning =
        false

    @State private var scanError:
        String?

    private let scanAPIService =
        ScanAPIService()


    // ============================================================
    // MARK: - Assembly Parts
    // ============================================================

    @State private var parts:
        [CarPart] = []

    @State private var isLoadingParts =
        false

    @State private var partsError:
        String?

    @State private var showingAssemblyDiagram =
        false

    private let partsAPIService =
        PartsAPIService()


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
                        .foregroundStyle(
                            .secondary
                        )
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
                        .multilineTextAlignment(
                            .center
                        )
                        .textSelection(
                            .enabled
                        )


                // =================================================
                // SIGNED IN
                // =================================================

                } else {

                    signedInContent
                }
            }
            .padding()
        }


        // ============================================================
        // MARK: - Admin Sheet
        // ============================================================

        .sheet(
            isPresented:
                $showingAdmin
        ) {

            if let token = idToken {

                AdminView(
                    idToken: token
                )
            }
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

                        showingImageCrop =
                            false


                        selectedImage =
                            croppedImage


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
    // MARK: - Signed-In Content
    // ================================================================

    @ViewBuilder
    private var signedInContent:
        some View {

        switch accessState {

        case .checking:

            accessCheckingView


        case .notRequested:

            accessRequestView


        case .pending:

            accessPendingView


        case .rejected:

            accessRejectedView


        case .approved:

            approvedAppView
        }
    }


    // ================================================================
    // MARK: - Checking Access
    // ================================================================

    private var accessCheckingView:
        some View {

        VStack(spacing: 16) {

            ProgressView()

            Text(
                "Checking your access…"
            )
            .font(.headline)

            Text(
                "Please wait while GolfParts verifies your account."
            )
            .font(.caption)
            .foregroundStyle(
                .secondary
            )
            .multilineTextAlignment(
                .center
            )
        }
        .padding()
    }


    // ================================================================
    // MARK: - Access Not Requested
    // ================================================================

    private var accessRequestView:
        some View {

        VStack(spacing: 18) {

            Image(
                systemName:
                    "lock.shield"
            )
            .font(
                .system(size: 48)
            )


            Text(
                "Access Required"
            )
            .font(.title2)
            .bold()


            Text(
                "You need approval before you can use the GolfParts application."
            )
            .foregroundStyle(
                .secondary
            )
            .multilineTextAlignment(
                .center
            )


            if let accessError {

                Text(accessError)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(
                        .center
                    )
            }


            Button {

                Task {

                    await requestAccess()
                }

            } label: {

                if isRequestingAccess {

                    ProgressView()

                } else {

                    Label(
                        "Request Access",
                        systemImage:
                            "paperplane"
                    )
                }
            }
            .buttonStyle(
                .borderedProminent
            )
            .disabled(
                isRequestingAccess
            )
        }
        .padding()
    }


    // ================================================================
    // MARK: - Pending Access
    // ================================================================

    private var accessPendingView:
        some View {

        VStack(spacing: 18) {

            Image(
                systemName:
                    "clock.badge.questionmark"
            )
            .font(
                .system(size: 48)
            )


            Text(
                "Access Request Pending"
            )
            .font(.title2)
            .bold()


            Text(
                "Your request has been sent to the administrator. Once it has been approved, you can continue using GolfParts."
            )
            .foregroundStyle(
                .secondary
            )
            .multilineTextAlignment(
                .center
            )


            if let accessError {

                Text(accessError)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(
                        .center
                    )
            }


            Button {

                Task {

                    await checkAccess()
                }

            } label: {

                Label(
                    "Check Again",
                    systemImage:
                        "arrow.clockwise"
                )
            }
            .buttonStyle(
                .borderedProminent
            )
        }
        .padding()
    }


    // ================================================================
    // MARK: - Rejected Access
    // ================================================================

    private var accessRejectedView:
        some View {

        VStack(spacing: 18) {

            Image(
                systemName:
                    "xmark.shield"
            )
            .font(
                .system(size: 48)
            )


            Text(
                "Access Not Approved"
            )
            .font(.title2)
            .bold()


            Text(
                "Your access request was not approved. You can submit a new request if needed."
            )
            .foregroundStyle(
                .secondary
            )
            .multilineTextAlignment(
                .center
            )


            if let accessError {

                Text(accessError)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(
                        .center
                    )
            }


            Button {

                Task {

                    await requestAccess()
                }

            } label: {

                if isRequestingAccess {

                    ProgressView()

                } else {

                    Label(
                        "Request Again",
                        systemImage:
                            "paperplane"
                    )
                }
            }
            .buttonStyle(
                .borderedProminent
            )
            .disabled(
                isRequestingAccess
            )
        }
        .padding()
    }


    // ================================================================
    // MARK: - Approved Application
    // ================================================================

    @ViewBuilder
    private var approvedAppView:
        some View {

        Text("Signed in ✓")
            .font(.headline)


        // ============================================================
        // Admin Button
        // ============================================================

        if isAdmin {

            Button {

                showingAdmin =
                    true

            } label: {

                Label(
                    "Admin",
                    systemImage:
                        "person.badge.key"
                )
            }
            .buttonStyle(
                .bordered
            )
        }


        // ------------------------------------------------------------
        // Selected image
        // ------------------------------------------------------------

        if let image =
            selectedImage {

            Image(
                uiImage:
                    image
            )
            .resizable()
            .scaledToFit()
            .frame(
                maxHeight:
                    300
            )
            .cornerRadius(
                12
            )
        }


        // ============================================================
        // Gemini Analysis
        // ============================================================

        if isScanning {

            VStack(spacing: 12) {

                ProgressView()
                    .controlSize(
                        .large
                    )


                Label(
                    "Gemini is analyzing the image…",
                    systemImage:
                        "sparkles"
                )
                .font(.headline)


                Text(
                    "AI is identifying the vehicle assembly. This can take a few seconds."
                )
                .font(.caption)
                .foregroundStyle(
                    .secondary
                )
                .multilineTextAlignment(
                    .center
                )
            }
            .padding()


        } else if let scanError {

            VStack(spacing: 12) {

                Image(
                    systemName:
                        "sparkles"
                )
                .font(
                    .largeTitle
                )


                Text(
                    "Couldn't analyze the image"
                )
                .font(
                    .headline
                )


                Text(
                    scanError
                )
                .font(
                    .caption
                )
                .foregroundStyle(
                    .secondary
                )
                .multilineTextAlignment(
                    .center
                )


                if let image =
                    selectedImage {

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


        } else if let result =
            scanResult {

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


                if result
                    .assemblyCode
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


        // ------------------------------------------------------------
        // Parts Loading
        // ------------------------------------------------------------

        if isLoadingParts {

            ProgressView(
                "Loading parts…"
            )
        }


        // ------------------------------------------------------------
        // Parts Error
        // ------------------------------------------------------------

        if let partsError {

            Text(
                partsError
            )
            .foregroundStyle(
                .red
            )
            .font(
                .caption
            )
            .multilineTextAlignment(
                .center
            )
        }


        // ============================================================
        // Scan Golf
        // ============================================================

        Button(
            "Scan Golf"
        ) {

            parts =
                []

            partsError =
                nil

            scanResult =
                nil

            scanError =
                nil

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


        Text(status)
            .font(.caption)
            .multilineTextAlignment(
                .center
            )
            .textSelection(
                .enabled
            )
    }


    // ================================================================
    // MARK: - Check Access
    // ================================================================

    @MainActor
    private func checkAccess() async {

        guard let token =
                idToken else {

            accessError =
                "No Google ID token available."

            return
        }


        accessError =
            nil


        do {

            let response =
                try await accessAPIService
                    .getMyAccessStatus(
                        idToken:
                            token
                    )


            updateAccessState(
                response.status
            )


        } catch {

            accessError =
                error.localizedDescription
        }
    }


    // ================================================================
    // MARK: - Request Access
    // ================================================================

    @MainActor
    private func requestAccess() async {

        guard let token =
                idToken else {

            accessError =
                "No Google ID token available."

            return
        }


        isRequestingAccess =
            true

        accessError =
            nil


        do {

            let response =
                try await accessAPIService
                    .requestAccess(
                        idToken:
                            token
                    )


            updateAccessState(
                response.status
            )


        } catch {

            accessError =
                error.localizedDescription
        }


        isRequestingAccess =
            false
    }


    // ================================================================
    // MARK: - Convert Backend Status to UI State
    // ================================================================

    @MainActor
    private func updateAccessState(
        _ status: String
    ) {

        switch status {

        case "APPROVED":

            accessState =
                .approved


        case "PENDING":

            accessState =
                .pending


        case "REJECTED":

            accessState =
                .rejected


        default:

            accessState =
                .notRequested
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


        guard accessState ==
                .approved else {

            status =
                "Your account does not have access."

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

            scanError =
                nil

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


        guard accessState ==
                .approved else {

            partsError =
                "Your account does not have access."

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


            parts =
                loadedParts


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


            print(
                "API /me HTTP:",
                code
            )


            print(
                "API /me response:",
                responseBody
            )


            if code == 200 {

                struct MeResponse:
                    Codable {

                    let subject:
                        String
                }


                if let me =
                    try? JSONDecoder()
                        .decode(
                            MeResponse.self,
                            from:
                                data
                        ) {

                    currentGoogleSub =
                        me.subject
                }


                // Google authentication succeeded.
                isSignedIn =
                    true


                // ----------------------------------------------------
                // IMPORTANT:
                // Authentication does NOT automatically mean the user
                // is allowed to use GolfParts.
                // ----------------------------------------------------

                accessState =
                    .checking


                status =
                    "Checking application access…"


                // Now ask our access-control API whether this user is
                // approved, pending, rejected or has never requested.
                await checkAccess()


                status =
                    "Signed in with Google"


            } else {

                currentGoogleSub =
                    nil

                isSignedIn =
                    false

                status =
                    """
                    API access failed
                    HTTP \(code)

                    \(responseBody)
                    """
            }


        } catch {

            currentGoogleSub =
                nil

            isSignedIn =
                false

            status =
                """
                Sign-in or network error:

                \(error.localizedDescription)
                """
        }
    }
}
