#!/bin/bash
set -e

echo "================ System Update ================"
sudo apt update -y && sudo apt upgrade -y


# ============================================================
# 1) Install Temurin JDK 17 (Latest)
# ============================================================
echo "================ Install Latest Temurin JDK 17 ================"

sudo mkdir -p /etc/apt/keyrings
wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public \
  | sudo tee /etc/apt/keyrings/adoptium.asc > /dev/null

echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] \
https://packages.adoptium.net/artifactory/deb $(awk -F= '/VERSION_CODENAME/{print $2}' /etc/os-release) main" \
| sudo tee /etc/apt/sources.list.d/adoptium.list

sudo apt update -y
sudo apt install -y temurin-17-jdk

java -version


# ============================================================
# 2) Install Jenkins (Latest LTS)
# ============================================================
echo "================ Install Latest Jenkins LTS ================"

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
  | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" \
| sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update -y
sudo apt install -y jenkins

sudo systemctl enable jenkins
sudo systemctl start jenkins


# ============================================================
# 3) Install Docker (Latest Docker CE, not old docker.io)
# ============================================================
echo "================ Install Latest Docker CE (Official) ================"

sudo apt remove -y docker.io containerd runc || true

sudo apt install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker $USER
sudo chmod 777 /var/run/docker.sock
sudo systemctl enable docker
sudo systemctl start docker


# ============================================================
# 4) Run SonarQube LTS (Latest)
# ============================================================
echo "================ Run Latest SonarQube LTS ================"

docker pull sonarqube:lts
docker run -d --name sonar -p 9000:9000 sonarqube:lts


# ============================================================
# 5) Install Trivy (Latest)
# ============================================================
echo "================ Install Latest Trivy ================"

sudo apt install -y wget gnupg lsb-release apt-transport-https

wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key \
  | sudo gpg --dearmor -o /usr/share/keyrings/trivy.gpg

echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] \
https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" \
| sudo tee /etc/apt/sources.list.d/trivy.list

sudo apt update -y
sudo apt install -y trivy

echo
echo "================ INSTALLATION COMPLETE ================"
echo "Jenkins URL:   http://<your-server-ip>:8080"
echo "SonarQube URL: http://<your-server-ip>:9000"
echo "Docker:        docker --version"
echo "Java:          java --version"
echo "Trivy:         trivy --version"
