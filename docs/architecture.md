# Architecture

## 1. High-level architecture

```text
iOS / SwiftUI
     |
     | HTTPS + JSON
     | Authorization: Bearer <Google ID token>
     v
Spring Security
     |
     v
Spring Boot Controllers
     |
     v
Services
     |
     +--------------------+
     |                    |
     v                    v
Spring Data JPA        Gemini API
     |
     v
PostgreSQL
```

The frontend never talks directly to PostgreSQL. It communicates only with the Spring Boot API.

---


## 2. Repository structure

```text
ai-gemini-vision-parts-finder/
├── backend/                  Spring Boot API
├── ios/                      SwiftUI iOS application
├── ACCESS_FLOW.md            Access-control notes
├── README.md
└── .github/                  CI configuration
```

### Backend package structure

```text
backend/src/main/java/com/divijwadhawan/golfparts/
├── GolfPartsApplication.java
├── SecurityConfig.java
├── MeController.java
├── auth/
├── catalog/
├── scan/
└── common/
```

The backend is organized as a modular monolith:

- `auth/` – authentication-related access requests and authorization policy
- `catalog/` – assemblies, parts, repositories and catalog business logic
- `scan/` – image upload, AI classification, rate limiting and scan history
- `common/` – health endpoint and shared API error handling

---


## 3. Backend

### Technology

- Java 25
- Spring Boot 4.1.1
- Spring MVC
- Spring Security
- OAuth2 Resource Server / JWT
- Spring Data JPA
- PostgreSQL
- Maven
- H2 for automated tests

The entry point is:

```text
backend/src/main/java/com/divijwadhawan/golfparts/GolfPartsApplication.java
```

### Request flow

A typical protected request follows this path:

```text
iPhone
  -> HTTP request + Google ID token
  -> Spring Security
  -> authorization policy
  -> Controller
  -> Service
  -> Repository
  -> PostgreSQL
  -> JSON response
  -> iPhone
```

### Security

The backend is stateless and expects a Google ID token in:

```http
Authorization: Bearer <GOOGLE_ID_TOKEN>
```

Spring Security validates the JWT issuer, signature, expiry and configured audience.

Authentication answers:

> Who is this user?

Application authorization then answers:

> Is this authenticated user allowed to use this part of the API?

The backend uses Google's stable `sub` claim as the user identifier.

### Access model

There are three practical user states:

- **admin** – identified by `APP_ADMIN_SUB`
- **approved user** – has an approved access request
- **signed-in but unapproved user** – authenticated but not allowed to use protected catalog/scan endpoints

Possible access-request states are:

```text
NOT_REQUESTED
PENDING
APPROVED
REJECTED
```

The admin can approve or reject requests.

---


## 5. AI provider design

The scan layer depends on the interface:

```java
public interface ImageAnalysisProvider {
    ScanResult analyze(byte[] image, String mimeType);
}
```

`ScanService` therefore does not depend directly on Gemini.

The current implementation is:

```text
GeminiImageAnalysisProvider
```

This provider:

- Base64-encodes the uploaded image
- sends it to Google's Gemini API
- requests structured JSON
- restricts classifications to known Golf 7 assembly codes
- normalizes Gemini's 0–1000 bounding-box coordinates to 0–1 values

There is also a `MockImageAnalysisProvider` in the codebase for controlled/non-production scenarios.

This interface makes it possible to add another image-analysis provider later without rewriting `ScanService`.

---


## 6. Database

The production backend uses PostgreSQL through Spring Data JPA.

Main persisted domains include:

- access requests
- assemblies
- car parts
- scan history

Typical backend flow:

```text
Controller
   -> Service
   -> JpaRepository
   -> PostgreSQL
```

Hibernate currently uses:

```properties
spring.jpa.hibernate.ddl-auto=update
```

For production evolution, schema migrations would normally be introduced instead of relying indefinitely on `ddl-auto=update`.

---


## 10. iOS frontend

The iOS app is under:

```text
ios/GolfParts_iOS/
```

It is built with SwiftUI.

The entry point is:

```text
MyApp.swift
```

which loads:

```text
ContentView.swift
```

### Main frontend responsibilities

`ContentView.swift` currently coordinates most of the user flow:

- checks whether the backend is reachable
- starts Google Sign-In
- stores the returned Google ID token
- calls `/me`
- checks the user's access state
- shows the correct access screen
- allows camera or photo-library image selection
- crops the selected image
- sends the image to `/scan`
- loads parts for the detected assembly
- opens the assembly diagram
- opens the admin screen for the configured admin

### Frontend service classes

#### `AccessAPIService.swift`

Handles:

```text
GET  /access-requests/me
POST /access-requests
```

#### `AdminAPIService.swift`

Handles:

```text
GET  /admin/access-requests
POST /admin/access-requests/{id}/approve
POST /admin/access-requests/{id}/reject
```

#### `PartsAPIService.swift`

Handles:

```text
GET /assemblies/{assemblyCode}/parts
```

#### `ScanAPIService.swift`

Uploads an image as `multipart/form-data` to:

```text
POST /scan
```

#### `BackendStatusService.swift`

Checks whether the backend is available.

### Frontend models

- `CarPart.swift` – data returned by the parts API
- `AccessRequest.swift` – admin-facing access-request data
- `ScanModels.swift` – scan result and bounding-box data

### UI support files

- `AdminView.swift` – administrator access-management screen
- `AssemblyDiagramView.swift` – visual assembly/parts screen
- `CameraPicker.swift` – native camera integration
- `PhotoPicker.swift` – photo-library integration
- `ImageCropView.swift` – crop/zoom step before scanning
- `Assets.xcassets` – assembly diagrams and part images

---


## 15. Known development notes

A few parts of the repository still show its learning-project history:

- the Maven artifact name is still `workput-api`
- `WorkputApiApplicationTests.java` retains the earlier name
- `ContentView.swift` currently contains substantial UI and application-flow logic and could later be refactored toward MVVM
- the iOS app currently contains an admin Google subject locally for showing the admin UI, but backend authorization remains authoritative

These do not change the backend access-control model.

---

