# Jenkins-CICD

![Arch Diagram ](../../CICD/Jenkins/images/arch-drawings/High_level_Arch.png)

## Installation on Azure Instance
![CICD Instance On Azure](../../CICD/Jenkins/images/misc/Azure_Jenkins.png)

### Install Jenkins.

Pre-Requisites:
 - Java (JDK)

### Run the below commands to install Java and Jenkins

Install Java

```
sudo apt update
sudo apt install openjdk-11-jre
```

Verify Java is Installed

```
java -version
```

Now, you can proceed with installing Jenkins

```
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins
```

**Note: ** By default, Jenkins will not be accessible to the external world due to the inbound traffic restriction by AWS. Open port 8080 in the inbound traffic rules as show below.

- Add inbound traffic rules as shown in the image (you can just allow TCP 8080).

![SG Azure VM](../../CICD/Jenkins/images/misc/SG.png)


### Login to Jenkins using the below URL:

http://<Azure-VM-public-ip-address>:8080    [You can get the address from your Azure console page]
  
After you login to Jenkins, 
      - Run the command to copy the Jenkins Admin Password - `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
      - Enter the Administrator password
      
![Unlock Jenkins ](../../CICD/Jenkins/images/misc/jenkins1.png)

### Click on Install suggested plugins

![Customize Jenkins ](../../CICD/Jenkins/images/misc/jenkins2.png)

Wait for the Jenkins to Install suggested plugins

![Installing Plugin on Jenkins](../../CICD/Jenkins/images/misc/jenkins3.png)

Create First Admin User or Skip the step [If you want to use this Jenkins instance for future use-cases as well, better to create admin user]

![Admin User Creation](../../CICD/Jenkins/images/misc/jenkins4.png)
Jenkins Installation is Successful. You can now starting using the Jenkins 

![Final Installation ](../../CICD/Jenkins/images/misc/jenkins5.png)

## Install the Docker Pipeline plugin in Jenkins:

   - Log in to Jenkins.
   - Go to Manage Jenkins > Manage Plugins.
   - In the Available tab, search for "Docker Pipeline".
   - Select the plugin and click the Install button.
   - Restart Jenkins after the plugin is installed.
   
![Docker Plugin ](../../CICD/Jenkins/images/misc/jenkins6.png)

Wait for the Jenkins to be restarted.


## Docker Slave Configuration

Run the below command to Install Docker

```
sudo apt update
sudo apt install docker.io
```
 
### Grant Jenkins user and Ubuntu user permission to docker deamon.

```
sudo su - 
usermod -aG docker jenkins
usermod -aG docker kishore
systemctl restart docker
```

Once you are done with the above steps, it is better to restart Jenkins.

```
http://<azure-vm-public-ip>:8080/restart
```

The docker agent configuration is now successful.

Install Jenkins, configure Docker as agent, set up cicd, deploy applications to k8s and much more.

# Spring Boot based Java web application
 
This is a simple Sprint Boot based Java application that can be built using Maven. Sprint Boot dependencies are handled using the pom.xml 
at the root directory of the repository.

This is a MVC architecture based application where controller returns a page with title and message attributes to the view.

## Execute the application locally and access it using your browser

Checkout the repo and move to the directory

```
git clone https://github.com/unplugged-kk/DevopsWKishore/CICD/Jenkins/java-maven-sonar-argocd-helm-k8s/sprint-boot-app
cd java-maven-sonar-argocd-helm-k8s/sprint-boot-app
```

Execute the Maven targets to generate the artifacts

```
mvn clean package
```

The above maven target stroes the artifacts to the `target` directory. You can either execute the artifact on your local machine
(or) run it as a Docker container.

** Note: To avoid issues with local setup, Java versions and other dependencies, I would recommend the docker way. **


### Execute locally (Java 11 needed) and access the application on http://localhost:8080

```
java -jar target/spring-boot-web.jar
```

### The Docker way

Build the Docker Image

```
docker build -t ultimate-cicd-pipeline:v1 .
```

```
docker run -d -p 8010:8080 -t ultimate-cicd-pipeline:v1
```

Hurray !! Access the application on `http://<ip-address>:8010`


## Next Steps

### Configure a Sonar Server locally

```
apt install unzip
adduser sonarqube
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.4.0.54424.zip
unzip sonarqube-9.4.0.54424.zip
chmod -R 755 /home/sonar/sonarqube-9.4.0.54424
chown -R sonar:sonar /home/sonarqube/sonarqube-9.4.0.54424
cd sonarqube-9.4.0.54424/bin/linux-x86-64/
./sonar.sh start
```

Hurray !! Now you can access the `SonarQube Server` on `http://<ip-address>:9000` 

