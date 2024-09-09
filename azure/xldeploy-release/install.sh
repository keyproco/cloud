#!/bin/bash

sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common -y

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install docker-ce -y

sudo usermod -aG docker $USER

sudo systemctl enable docker

sudo systemctl start docker

# xl deploy & release volumes
mkdir -p /XebiaLabs/xl-deploy-server/conf
mkdir -p /XebiaLabs/xl-deploy-server/hotfix/lib
mkdir -p /XebiaLabs/xl-deploy-server/hotfix/plugins
mkdir -p /XebiaLabs/xl-deploy-server/ext
mkdir -p /XebiaLabs/xl-deploy-server/plugins
mkdir -p /XebiaLabs/xl-deploy-server/repository
mkdir -p /XebiaLabs/xl-deploy-server/repository
mkdir -p /XebiaLabs/xl-deploy-server/repository

mkdir -p /XebiaLabs/xl-release-server/conf
mkdir -p /XebiaLabs/xl-release-server/hotfix/
mkdir -p /XebiaLabs/xl-release-server/ext
mkdir -p /XebiaLabs/xl-release-server/plugins
mkdir -p /XebiaLabs/xl-release-server/repository
mkdir -p /XebiaLabs/xl-release-server/archive
mkdir -p /XebiaLabs/xl-release-server/archive

sudo chown -R 10001 /XebiaLabs/
#!/bin/bash

cat >> docker-compose.yml << EOF
version: "2"
services:
  xld:
    image: xebialabs/xl-deploy:24.1
    container_name: xld
    ports:
      - "4516:4516"
    volumes:
      - /XebiaLabs/xl-deploy-server/conf:/opt/xebialabs/xl-deploy-server/conf
      - /XebiaLabs/xl-deploy-server/hotfix/lib:/opt/xebialabs/xl-deploy-server/hotfix/lib
      - /XebiaLabs/xl-deploy-server/hotfix/plugins:/opt/xebialabs/xl-deploy-server/hotfix/plugins
      - /XebiaLabs/xl-deploy-server/ext:/opt/xebialabs/xl-deploy-server/ext
      - /XebiaLabs/xl-deploy-server/plugins:/opt/xebialabs/xl-deploy-server/plugins
      - /XebiaLabs/xl-deploy-server/repository:/opt/xebialabs/xl-deploy-server/repository
      - /XebiaLabs/xl-deploy-server/repository:/opt/xebialabs/xl-deploy-server/export
      - /XebiaLabs/xl-deploy-server/repository:/opt/xebialabs/xl-deploy-server/work
    environment:
      - ADMIN_PASSWORD=admin
      - ACCEPT_EULA=Y

  xlr:
    image: xebialabs/xl-release:24.1
    container_name: xlr
    ports:
      - "5516:5516"
    links:
      - xld
    volumes:
      - /XebiaLabs/xl-release-server/conf:/opt/xebialabs/xl-release-server/conf
      - /XebiaLabs/xl-release-server/hotfix/:/opt/xebialabs/xl-release-server/hotfix/
      - /XebiaLabs/xl-release-server/ext:/opt/xebialabs/xl-release-server/ext
      - /XebiaLabs/xl-release-server/plugins:/opt/xebialabs/xl-release-server/plugins
      - /XebiaLabs/xl-release-server/repository:/opt/xebialabs/xl-release-server/repository
      - /XebiaLabs/xl-release-server/archive:/opt/xebialabs/xl-release-server/archive
      - /XebiaLabs/xl-release-server/archive:/opt/xebialabs/xl-release-server/reports
    environment:
      - ADMIN_PASSWORD=admin
      - ACCEPT_EULA=Y
EOF

# docker-compose up -f /docker-compose.yaml -d 
