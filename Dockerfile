# STAGE 1: Build the application
FROM swift:5.10 AS build

# Set the working directory
WORKDIR /app

# Copy package manifests
COPY Package.swift ./
COPY Package.resolved ./

# Resolve dependencies
RUN swift package resolve

# Copy the rest of the source code
COPY . .

# Build the release executable with static linking
RUN swift build --configuration release --product App --static-swift-stdlib

# STAGE 2: Create the production image
FROM ubuntu:22.04

# Set the working directory
WORKDIR /app

# Install runtime dependencies
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y libjemalloc2 libatomic1 \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN groupadd --gid 1000 vapor \
    && useradd --uid 1000 --gid 1000 --create-home vapor

# Copy the built executable from the build stage
COPY --from=build /app/.build/release/App ./Run

# Copy Public resources if they exist
COPY --from=build /app/Public ./Public

# Switch to non-root user
USER vapor:vapor

# Expose the port the app runs on
EXPOSE 8080

# Set the container's entrypoint
ENTRYPOINT ["./Run", "serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]