# --- Build the official Conductor "server" image from source ---
# This mirrors the docs: build docker/server/Dockerfile from the repo.
# Pin to a tag/branch to avoid surprises. Example: v3.15.0 (adjust if needed).

ARG CONDUCTOR_REF=v3.15.0

FROM alpine:3.19 AS fetch
RUN apk add --no-cache git
WORKDIR /src
RUN git clone https://github.com/conductor-oss/conductor.git . && \
    git checkout ${CONDUCTOR_REF}

# Build the server image using the official Dockerfile
# The Dockerfile path is docker/server/Dockerfile inside the repo.
FROM docker:27.0-cli AS dind
WORKDIR /src
COPY --from=fetch /src /src
# Build inner image named conductor:server (as per docs)
RUN docker build -t conductor:server -f docker/server/Dockerfile /src

# --- Final: run the built server image as our container ---
# Extract layers from the just-built image and run it
FROM conductor:server

# Conductor server image already exposes 8080 and starts via its entrypoint.
# Railway will hit 0.0.0.0:$PORT; we set SERVER_PORT/PORT via env in Railway.
