# Use the official SonarQube image as the base
FROM sonarqube:8.9.2-community

# Set the user
USER sonarqube

# Create data directory as a Docker volume
VOLUME /opt/sonarqube/data

# Expose the SonarQube port
EXPOSE 9000

# Define the entry point script
COPY entrypoint.sh /entrypoint.sh
#RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
