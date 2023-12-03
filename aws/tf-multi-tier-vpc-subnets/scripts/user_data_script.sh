#!/bin/bash
sudo yum update -y


sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

dnf install wget php-mysqlnd httpd php-fpm php-mysqli mariadb105-server php-json php php-devel stress -y
sudo systemctl enable httpd mariadb
sudo systemctl start httpd mariadb


sudo wget https://wordpress.org/latest.tar.gz -P /var/www/html

cd /var/www/html
sudo sudo tar -zxvf latest.tar.gz
sudo cp -rvf wordpress/* .
sudo rm -R wordpress
sudo rm latest.tar.gz

sudo cp ./wp-config-sample.php ./wp-config.php

sudo sed -i "s/'database_name_here'/'${DBName}'/g" wp-config.php
sudo sed -i "s/'username_here'/'${DBUser}'/g" wp-config.php
sudo sed -i "s/'password_here'/'${DBPassword}'/g" wp-config.php
sudo sed -i "s/'localhost'/'${DBEndpoint}'/g" wp-config.php
sudo usermod -a -G apache ec2-user   
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www
sudo find /var/www -type d -exec chmod 2775 {} \;
sudo find /var/www -type f -exec chmod 0664 {} \;


sudo mysqladmin -u root password "${DBRootPassword}"
sudo echo "CREATE DATABASE ${DBName};" >> /tmp/db.setup
sudo echo "CREATE USER '${DBUser}'@'localhost' IDENTIFIED BY '${DBPassword}';" >> /tmp/db.setup
sudo echo "GRANT ALL ON ${DBName}.* TO ${DBUser}@'localhost';" >> /tmp/db.setup
sudo echo "FLUSH PRIVILEGES;" >> /tmp/db.setup
sudo mysql -u root --password="${DBRootPassword}" < /tmp/db.setup

