FROM gradle:8.7-jdk21 AS builder
WORKDIR /app

COPY gradlew build.gradle.kts settings.gradle.kts ./
COPY gradle ./gradle
COPY src ./src

RUN chmod +x gradlew && ./gradlew bootJar --no-daemon

FROM eclipse-temurin:21-jre
WORKDIR /service

COPY --from=builder /app/build/libs/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
