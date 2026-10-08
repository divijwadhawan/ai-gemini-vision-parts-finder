# Demonstration

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


## Verification

Backend tests are present; this documentation update does not certify the deployed API or an iPhone build. Record the device, build, date and observed result when demonstrating the application.
