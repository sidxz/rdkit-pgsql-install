#!/bin/bash

# Check if .env file exists
if [ ! -f .env ]; then
  echo ".env file not found!"
  exit 1
fi

# Export environment variables from .env file
export $(grep -v '^#' .env | xargs)

# Check if POSTGRES_USER and POSTGRES_PASSWORD are set
if [ -z "$POSTGRES_USER" ] || [ -z "$POSTGRES_PASSWORD" ]; then
  echo "POSTGRES_USER and POSTGRES_PASSWORD must be set in the .env file!"
  exit 1
fi

# Check if /data directory exists
if [ ! -d /data ]; then
  echo "/data directory does not exist!"
  exit 1
fi

# Start Docker Compose
echo "Starting Docker Compose..."
docker compose -f docker-compose.yml up --force-recreate -d

echo "Docker Compose started successfully."
