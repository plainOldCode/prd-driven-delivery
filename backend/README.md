# Backend

This is a sample Kotlin + Spring Boot API server.

## Included

- `/api/health` status endpoint
- `/api/tasks` database-backed endpoint
- MariaDB datasource for local and containerized execution
- Java 21 toolchain
- Liquibase changelog skeleton

## Run

```bash
cd ../database/dockerized
docker compose up -d

cd ../../backend
docker compose up --build -d
```

The backend container expects MariaDB to be reachable on `localhost:3306` from the host. That matches the database project defaults.

For a non-container run:

```bash
cd backend
./gradlew bootRun
```

That local path requires JDK 21.
