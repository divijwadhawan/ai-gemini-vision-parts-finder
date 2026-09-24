# GolfParts access requests

The API verifies Google ID tokens and uses the verified `sub` claim as the
account identifier. Authentication alone does not grant access to the parts
catalog. `/me` remains available to signed-in users so the owner can obtain
their Google subject for initial admin setup.

## Initial owner setup (required before merging/deploying)

Set `APP_ADMIN_SUB` on the Render JavaLearning service to the `subject` returned
by `GET /me` while signed in as the owner. Keep `GOOGLE_CLIENT_ID` configured to
the Google Web/server OAuth client ID used by the iOS app. Do not use an email
address or client ID for `APP_ADMIN_SUB`. If the variable is absent, nobody has
admin access and new users cannot be approved. The owner can read parts without
submitting a request.

## API flow

All calls use `Authorization: Bearer <GOOGLE_ID_TOKEN>`.

| Method | Path | Who | Result |
| --- | --- | --- | --- |
| GET | `/me` | Any signed-in user | `{"subject":"..."}` |
| GET | `/access-requests/me` | Any signed-in user | `{"status":"NOT_REQUESTED"}` (or `PENDING`, `APPROVED`, `REJECTED`) |
| POST | `/access-requests` | Any signed-in user | Creates a pending request; repeat calls do not duplicate it. A rejected user can resubmit. |
| GET | `/vehicles/{vehicle}/areas/{area}/parts` | Owner or approved user | Parts list; unapproved users receive 403. |
| GET | `/admin/access-requests` | Owner | Requests, including IDs, verified emails when available, status, and timestamps. |
| POST | `/admin/access-requests/{id}/approve` | Owner | Approves the request. |
| POST | `/admin/access-requests/{id}/reject` | Owner | Rejects or revokes access. |
| POST | `/parts` | Owner | Creates a part. |

The Google email is shown to the owner only when the token includes
`email_verified=true`; authorization is always keyed to `sub`. The owner can
review requests with an HTTP client using their ID token. A future admin screen
can use the same endpoints.

## Suggested iOS screen

After Google sign-in, call `GET /access-requests/me`. For `NOT_REQUESTED` or
`REJECTED`, show **Request access** and call `POST /access-requests` when tapped.
For `PENDING`, show **Waiting for approval** with a refresh button. For
`APPROVED`, show the GolfParts areas and fetch parts. Do not treat a successful
Google sign-in or a local UI flag as permission to fetch parts.
