#!/bin/bash
sudo yum update -y
sudo yum install apache2 -y
sudo yum install php libapache2-mod-php -y
sudo service apache2 restart -y
