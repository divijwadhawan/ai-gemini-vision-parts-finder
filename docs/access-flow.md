# Authentication and access

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

