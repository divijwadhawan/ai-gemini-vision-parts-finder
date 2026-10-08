# Gemini Vision Parts Finder

Recognize a VW Golf 7 assembly from a photo and browse its catalog of parts. A SwiftUI app calls a Java Spring Boot API, which uses Gemini for image analysis and PostgreSQL for persistence.

**Status:** implemented prototype. The catalog covers five assemblies; this is not a general vehicle-identification or production ordering system.

## Demo
Sign in, request access, obtain admin approval, take or select a photo, and view the detected assembly and its parts. See the [demo walkthrough](docs/demo.md).

## Implemented features
- Google ID-token authentication and server-side approval of application access.
- Assembly and parts catalog, plus an administrator access-management screen.
- Gemini image classification with a bounding box.
- Scan history, upload constraints and per-user scan rate limiting.

## Architecture and stack
SwiftUI → authenticated REST API → Spring Security → catalog/scan services → PostgreSQL and Gemini.

Java 25, Spring Boot 4.1.1, Maven, Spring Data JPA, PostgreSQL, SwiftUI and Google Sign-In. The backend separates `auth`, `catalog`, `scan` and `common` concerns.

## Quick start
1. Configure database, Google audience/admin subject and Gemini environment variables using the [setup guide](docs/setup.md).
2. Run `cd backend && ./mvnw spring-boot:run`.
3. Open `ios/GolfParts_iOS.xcodeproj` in Xcode; configure signing and Google Sign-In.
4. Complete the [access flow](docs/access-flow.md).

## Project scope and attribution
This portfolio project integrates mobile capture, backend access control, an automotive catalog and an external vision model. Gemini performs the image analysis; model training is not part of this repository. Catalog data and images should be reviewed for source attribution and redistribution rights.

## Validation and limitations
Backend tests and a GitHub Actions workflow are included. Run `cd backend && ./mvnw test`. No tests or device builds were run as part of this documentation restructuring.

The prototype uses Hibernate schema updates, a limited Golf 7 catalog and a single configured administrator. Legacy workout classes and the Maven artifact `workput-api` remain from the project's earlier iteration; see [development notes](docs/architecture.md). Physical-device behavior and deployed-service availability require separate verification.

## Documentation
- [Architecture](docs/architecture.md)
- [Setup](docs/setup.md)
- [API reference](docs/api.md)
- [Authentication and access](docs/access-flow.md)
- [Demo](docs/demo.md)

## License
No root licence file is currently provided. Public visibility alone does not grant an open-source licence.
