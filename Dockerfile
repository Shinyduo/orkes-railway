# --- Build Conductor OSS server from source ---
FROM eclipse-temurin:17-jdk AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates curl && rm -rf /var/lib/apt/lists/*

# Pin to a tag (matches your attempt)
ARG CONDUCTOR_REF=v3.21.19
RUN git clone https://github.com/conductor-oss/conductor.git . \
 && git checkout ${CONDUCTOR_REF}

# Ensure gradle wrapper can run
RUN chmod +x ./gradlew

# IMPORTANT: build FROM THE server dir (or -p server)
RUN ./gradlew -p server bootJar -x test --no-daemon

# --- Runtime image ---
FROM eclipse-temurin:17-jre
WORKDIR /app

# Copy the Spring Boot fat jar (bootJar ends with -boot.jar)
COPY --from=builder /app/server/build/libs/*-boot.jar /app/conductor-server.jar

# Railway port wiring
ENV PORT=8080
ENV SERVER_PORT=8080
EXPOSE 8080

ENTRYPOINT ["java","-jar","/app/conductor-server.jar"]
