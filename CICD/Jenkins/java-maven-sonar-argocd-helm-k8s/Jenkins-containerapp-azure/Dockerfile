# Use the official Jenkins LTS image as the base
FROM jenkins/jenkins:lts

# Set the user to root for installation
USER root

# Install necessary packages and dependencies
RUN apt-get update && \
    apt-get install -y sudo

# Create Jenkins data directory as a Docker volume
VOLUME /var/jenkins_home

# Set permissions for Jenkins data directory
RUN chown -R jenkins:jenkins /var/jenkins_home

# Switch back to the jenkins user
USER jenkins

# Install Jenkins plugins (if needed)
# Example: COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
# Example: RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

# Define any additional Jenkins configurations (if needed)
# Example: COPY config.xml /var/jenkins_home/config.xml

# Expose the Jenkins web interface port
EXPOSE 8080

# Start Jenkins
CMD ["/usr/local/bin/jenkins.sh"]