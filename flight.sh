#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
  echo "Docker is not installed. Please install Docker first."
  exit 1
fi


# Check if .env file exists
if [ ! -f .env ]; then
  echo ".env file not found!"
  exit 1
fi

# Export environment variables from .env file
set -a
source .env
set +a

# Check if POSTGRES_USER and POSTGRES_PASSWORD are set
if [ -z "$POSTGRES_USER" ] || [ -z "$POSTGRES_PASSWORD" ]; then
  echo "POSTGRES_USER and POSTGRES_PASSWORD must be set in the .env file!"
  exit 1
fi

# Check if /data directory exists
if [ ! -d /data/moldb ]; then
  echo "/data/moldb directory does not exist!"
  exit 1
fi

# Check if docker-compose.yml file exists
if [ ! -f docker-compose.yml ]; then
  echo "docker-compose.yml file not found!"
  exit 1
fi

# Start Docker Compose
echo "Starting Docker Compose..."
docker compose -f docker-compose.yml up --force-recreate -d
if [ $? -ne 0 ]; then
    echo "Failed to start Docker Compose."
    exit 1
fi

echo "Docker Compose started successfully."
