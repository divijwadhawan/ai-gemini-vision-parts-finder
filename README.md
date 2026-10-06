# JavaLearning – GolfParts

A full-stack learning project built to understand modern Java/Spring Boot backend development and how a native iOS frontend consumes a secured REST API.

The project contains:

- a **Spring Boot backend** in `backend/`
- a **SwiftUI iOS frontend** in `ios/`
- Google ID-token based authentication
- an approval workflow for API access
- a small Golf 7 parts catalog backed by PostgreSQL
- an image-scan flow that classifies a vehicle area with Gemini and returns the matching assembly
- backend tests using JUnit, Spring Security test support and H2

The deployed API is currently consumed by the iOS app at:

```text
https://api.divijwadhawan.com
```

---

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
JavaLearning/
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

## 4. Backend API

All endpoints except `/health` require authentication unless noted otherwise.

### Health

```http
GET /health
```

Public health check.

Example response:

```json
{
  "status": "UP"
}
```

### Current user

```http
GET /me
Authorization: Bearer <GOOGLE_ID_TOKEN>
```

Returns the authenticated Google subject.

Example:

```json
{
  "subject": "106707840647310647835"
}
```

### Access request

Check the current user's access state:

```http
GET /access-requests/me
Authorization: Bearer <GOOGLE_ID_TOKEN>
```

Request access:

```http
POST /access-requests
Authorization: Bearer <GOOGLE_ID_TOKEN>
```

A new request is created as `PENDING`. A previously rejected user can resubmit.

### Admin access-management endpoints

Admin only:

```http
GET /admin/access-requests
POST /admin/access-requests/{id}/approve
POST /admin/access-requests/{id}/reject
```

The backend authorizes these calls with `AccessPolicy.isAdmin(...)`.

### Catalog

List assemblies:

```http
GET /assemblies
```

List parts for an assembly:

```http
GET /assemblies/{code}/parts
```

Example assembly codes used by the image classifier include:

```text
FRONT_BUMPER
ENGINE
REAR_BUMPER
SIDE_MIRROR
DOOR
```

Create a new part:

```http
POST /parts
Content-Type: application/json
```

This endpoint is admin-only.

### Image scan

```http
POST /scan
Content-Type: multipart/form-data
Authorization: Bearer <GOOGLE_ID_TOKEN>
```

The form field must be named:

```text
image
```

The backend:

1. validates that the file is JPEG or PNG
2. limits the image to 10 MB
3. rate-limits users to 5 scans per minute
4. passes the image to the configured `ImageAnalysisProvider`
5. uses Gemini to classify the visible Golf 7 assembly
6. validates that the returned assembly exists in the catalog
7. stores successful scan metadata in PostgreSQL
8. returns the classification and bounding box

Example response:

```json
{
  "assemblyCode": "SIDE_MIRROR",
  "confidence": 0.93,
  "boundingBox": {
    "x": 0.12,
    "y": 0.22,
    "width": 0.31,
    "height": 0.28
  }
}
```

The user can also retrieve their own scan history:

```http
GET /scans/me
```

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

## 7. Backend configuration

The main configuration is in:

```text
backend/src/main/resources/application.properties
```

The runtime expects these environment variables:

| Variable | Purpose |
| --- | --- |
| `DB_URL` | PostgreSQL JDBC URL |
| `DB_USER` | PostgreSQL username |
| `DB_PASSWORD` | PostgreSQL password |
| `GOOGLE_CLIENT_ID` | expected Google ID-token audience |
| `APP_ADMIN_SUB` | Google `sub` for the single admin |
| `GEMINI_API_KEY` | Gemini API key |
| `PORT` | server port; defaults to 8080 |

Example:

```bash
export DB_URL=jdbc:postgresql://...
export DB_USER=...
export DB_PASSWORD=...
export GOOGLE_CLIENT_ID=...
export APP_ADMIN_SUB=...
export GEMINI_API_KEY=...
```

Do not commit real secrets.

---

## 8. Running the backend locally

From the repository:

```bash
cd backend
./mvnw spring-boot:run
```

or, if Maven is installed globally:

```bash
mvn spring-boot:run
```

To build:

```bash
mvn package
```

To run the test suite:

```bash
mvn test
```

---

## 9. Backend tests

Tests are under:

```text
backend/src/test/java/com/divijwadhawan/golfparts/
```

Current test classes include:

- `AccessPolicyTest.java`
- `AccessRequestSecurityTest.java`
- `ScanSecurityTest.java`
- `WorkputApiApplicationTests.java`
- `scan/ScanServiceTest.java`

Tests use the configuration in:

```text
backend/src/test/resources/application.properties
```

The test profile uses an isolated in-memory H2 database rather than the production PostgreSQL database.

The test Gemini key is a dummy value, so automated tests do not call the real Gemini service.

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

## 11. How the frontend gets access to the API

This is the most important cross-application flow.

### Step 1 – Google Sign-In

The iOS app is configured with Google Sign-In in:

```text
ios/GolfParts-iOS-Info.plist
```

It contains both the iOS client ID and a server client ID.

The frontend signs the user in with Google and obtains a Google **ID token**.

The API expects the ID token, not a generic OAuth access token.

### Step 2 – Send the token to Spring Boot

Every protected frontend API request sends:

```http
Authorization: Bearer <GOOGLE_ID_TOKEN>
```

For example, `AccessAPIService`, `PartsAPIService`, `ScanAPIService` and `AdminAPIService` all attach the token this way.

### Step 3 – Verify authentication

The frontend first calls:

```http
GET /me
Authorization: Bearer <GOOGLE_ID_TOKEN>
```

If Spring Security accepts the token, the API returns the user's Google `sub`.

### Step 4 – Check application access

Being authenticated does **not** automatically grant GolfParts access.

The frontend calls:

```http
GET /access-requests/me
Authorization: Bearer <GOOGLE_ID_TOKEN>
```

The response is one of:

```text
NOT_REQUESTED
PENDING
APPROVED
REJECTED
```

### Step 5 – Request access

If the user has never requested access, the app calls:

```http
POST /access-requests
Authorization: Bearer <GOOGLE_ID_TOKEN>
```

The request becomes `PENDING`.

### Step 6 – Admin approval

The configured admin opens the admin UI.

The frontend calls:

```http
GET /admin/access-requests
```

and can then call:

```http
POST /admin/access-requests/{id}/approve
```

or:

```http
POST /admin/access-requests/{id}/reject
```

### Step 7 – Use protected functionality

Once the backend reports `APPROVED`, the frontend can access protected endpoints such as:

```text
GET  /assemblies
GET  /assemblies/{code}/parts
POST /scan
GET  /scans/me
```

The server performs authorization on every request. A local frontend flag alone does not grant access.

### Access flow diagram

```text
User
 |
 v
Google Sign-In
 |
 | ID token
 v
GET /me
 |
 | authenticated?
 v
GET /access-requests/me
 |
 +--> NOT_REQUESTED --> POST /access-requests
 |                         |
 |                         v
 |                      PENDING
 |                         |
 |                    Admin approval
 |                         |
 +-------------------------+
 |
 v
APPROVED
 |
 +--> GET /assemblies
 +--> GET /assemblies/{code}/parts
 +--> POST /scan
 +--> GET /scans/me
```

---

## 12. Example frontend-to-backend requests

### Check identity

```bash
curl https://api.divijwadhawan.com/me \
  -H "Authorization: Bearer <GOOGLE_ID_TOKEN>"
```

### Check access state

```bash
curl https://api.divijwadhawan.com/access-requests/me \
  -H "Authorization: Bearer <GOOGLE_ID_TOKEN>"
```

### Request access

```bash
curl -X POST https://api.divijwadhawan.com/access-requests \
  -H "Authorization: Bearer <GOOGLE_ID_TOKEN>"
```

### List parts

```bash
curl https://api.divijwadhawan.com/assemblies/SIDE_MIRROR/parts \
  -H "Authorization: Bearer <GOOGLE_ID_TOKEN>"
```

### Scan an image

```bash
curl -X POST https://api.divijwadhawan.com/scan \
  -H "Authorization: Bearer <GOOGLE_ID_TOKEN>" \
  -F "image=@golf.jpg;type=image/jpeg"
```

---

## 13. Typical user journey

```text
1. Launch iOS app
2. App checks backend status
3. Sign in with Google
4. iOS receives Google ID token
5. App verifies token against GET /me
6. App asks backend for access status
7. New user submits an access request
8. Admin approves the request
9. User becomes APPROVED
10. User takes or selects a Golf 7 photo
11. App allows cropping/zooming
12. iOS uploads the image to POST /scan
13. Backend asks Gemini to identify the assembly
14. Backend returns assemblyCode + confidence + bounding box
15. iOS requests parts for that assembly
16. App displays the assembly diagram and matching parts
```

---

## 14. Security notes

- Real database credentials and API keys belong in environment variables.
- The Google ID token is validated by Spring Security on the backend.
- Authorization is based on Google's stable `sub`, not email.
- The server decides whether a user is approved; the frontend does not.
- Admin access is controlled by `APP_ADMIN_SUB`.
- The API is stateless.
- `/health` is public; application endpoints are protected according to `SecurityConfig`.
- Uploaded images are limited to JPEG/PNG and 10 MB.
- The current scan limiter allows 5 scan requests per minute per Google subject.

---

## 15. Known development notes

A few parts of the repository still show its learning-project history:

- the Maven artifact name is still `workput-api`
- `WorkputApiApplicationTests.java` retains the earlier name
- `ContentView.swift` currently contains substantial UI and application-flow logic and could later be refactored toward MVVM
- the iOS app currently contains an admin Google subject locally for showing the admin UI, but backend authorization remains authoritative

These do not change the backend access-control model.

---

## 16. Quick summary

The project demonstrates a complete authenticated flow:

```text
SwiftUI frontend
   -> Google Sign-In
   -> Google ID token
   -> Spring Security
   -> application approval policy
   -> Spring MVC / services
   -> JPA / PostgreSQL
   -> Gemini image classification
   -> JSON response
   -> SwiftUI presentation
```

The important design rule is:

> **Authentication comes from Google, but application access is decided by the Spring Boot backend.**
