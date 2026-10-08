# Setup and configuration

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

