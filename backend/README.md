# Backend

This is a sample Kotlin + Spring Boot API server.

## Included

- `/api/health` status endpoint
- H2 datasource for default local execution
- `mariadb` profile for database-backed runs
- Liquibase changelog skeleton

## Run

```bash
cd backend
gradle bootRun
```

To run against MariaDB:

```bash
SPRING_PROFILES_ACTIVE=mariadb gradle bootRun
```
