# --- Build Conductor OSS server from source (no Docker-in-Docker) ---
FROM eclipse-temurin:17-jdk AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates && rm -rf /var/lib/apt/lists/*

# Pin to a known tag; you can bump later. Check repo tags if needed.
ARG CONDUCTOR_REF=v3.21.19
RUN git clone https://github.com/conductor-oss/conductor.git . \
 && git checkout ${CONDUCTOR_REF}

# Build ONLY the server jar; skip tests for faster CI
RUN ./gradlew :server:bootJar -x test

# --- Runtime image ---
FROM eclipse-temurin:17-jre
WORKDIR /app

# Copy the spring-boot fat jar
COPY --from=builder /app/server/build/libs/*.jar /app/conductor-server.jar

# Railway expects the app to listen on 0.0.0.0:$PORT. We'll use 8080.
ENV PORT=8080
ENV SERVER_PORT=8080
EXPOSE 8080

# Spring Boot respects SERVER_PORT
ENTRYPOINT ["java","-jar","/app/conductor-server.jar"]
