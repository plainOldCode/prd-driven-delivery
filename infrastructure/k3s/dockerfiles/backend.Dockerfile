FROM gradle:8.7-jdk21 AS builder
WORKDIR /app

COPY backend/build.gradle.kts backend/settings.gradle.kts ./
COPY backend/src ./src

RUN gradle bootJar --no-daemon

FROM eclipse-temurin:21-jre
WORKDIR /service

COPY --from=builder /app/build/libs/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
