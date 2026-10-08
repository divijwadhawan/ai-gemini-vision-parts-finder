# API reference

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

