# Minimal Dockerfile for desktop-tutorial repository
# This allows the Anchore security scanning workflow to run successfully

FROM alpine:latest

# Add a label for documentation
LABEL maintainer="desktop-tutorial"
LABEL description="Minimal Docker image for GitHub Desktop tutorial repository"

# Create a simple directory structure
RUN mkdir -p /app

# Set working directory
WORKDIR /app

# Add repository files
COPY . .

# Default command
CMD ["/bin/sh"]
