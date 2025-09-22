FROM eclipse-temurin:17-jre
WORKDIR /app

# Pick a version (e.g., the latest release tag)
ARG CONDUCTOR_VER=3.21.19
# Download the prebuilt boot jar
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates && rm -rf /var/lib/apt/lists/* \
 && curl -fSL "https://repo1.maven.org/maven2/org/conductoross/conductor-server/${CONDUCTOR_VER}/conductor-core-${CONDUCTOR_VER}-boot.jar" \
      -o /app/conductor-server.jar

ENV PORT=8080
ENV SERVER_PORT=8080
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/conductor-server.jar"]
