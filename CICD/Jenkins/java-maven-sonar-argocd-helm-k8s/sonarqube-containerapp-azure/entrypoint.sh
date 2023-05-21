#!/bin/bash

set -e

# Start SonarQube
./bin/run.sh &

# Wait for SonarQube to start
until $(curl --output /dev/null --silent --head --fail http://localhost:9000); do
  echo "Waiting for SonarQube to start..."
  sleep 5
done

# Run any additional setup or configuration if needed

# Keep the container running
tail -f /dev/null