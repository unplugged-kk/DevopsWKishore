# Base image
FROM openjdk:8-jre-alpine

# Set the SonarQube version
ARG SONARQUBE_VERSION=9.1.0.47736

# Set the download URL for SonarQube
ARG SONARQUBE_DOWNLOAD_URL=https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip

# Install unzip and bash
RUN apk add --no-cache unzip bash

# Download and extract SonarQube
RUN set -x \
    && cd /opt \
    && wget -O sonarqube.zip ${SONARQUBE_DOWNLOAD_URL} \
    && unzip sonarqube.zip \
    && mv sonarqube-${SONARQUBE_VERSION} sonarqube \
    && rm sonarqube.zip*

# Configure environment variables
ENV SONAR_HOME=/opt/sonarqube \
    PATH=$PATH:/opt/sonarqube/bin

# Expose the default port for SonarQube
EXPOSE 9000

# Start SonarQube
CMD ["./bin/run.sh"]
