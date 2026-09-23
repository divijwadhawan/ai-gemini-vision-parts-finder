# JavaLearning

## Google sign-in for the car parts API

The Spring Boot API in `workput-api/` accepts **Google ID tokens** in the
`Authorization: Bearer <ID_TOKEN>` header. It verifies Google's signature,
issuer, expiration, and the intended OAuth client ID (audience). Apple ID
tokens are no longer accepted.

### Configuration

1. Create a Google OAuth client ID for the iOS application in Google Cloud,
   and configure Google Sign-In in the separate Xcode project.
2. Set `GOOGLE_CLIENT_ID` in the API environment (for example, Render) to
   the **exact value of the `aud` claim** in the Google ID token your app
   sends. If your iOS sign-in flow requests a token for a server/web client,
   use that server client ID; otherwise use the iOS client ID. Do not set this
   to the iOS bundle ID or the Apple Team ID.
3. Sign in within the iOS app, obtain the Google **ID token**, and send it
   with every protected API request, for example:
   `Authorization: Bearer <ID_TOKEN>`.
   An OAuth access token is not interchangeable with an ID token here.
4. Call `GET /me` to verify authentication. It returns the Google
   account's stable subject (`sub`). For write access to `POST /parts`,
   set `APP_ADMIN_SUB` in the API environment to that subject. The old
   Apple subject will no longer identify the Google account.

Until `GOOGLE_CLIENT_ID` is configured, the API uses an `unconfigured`
audience so regular Google ID tokens cannot authenticate. The iOS Xcode
project is not stored in this repository; updating its button, URL scheme,
Google client configuration, and token handling must be done there.
