#!/bin/sh

echo "I'm alive!"

echo "Mounting the data..."
sudo mkdir /mnt/tweet_data
sudo mount /dev/vdb1 /mnt/tweet_data
sudo chown ubuntu:ubuntu /mnt/tweet_data

sudo apt-get update -y
sudo apt-get upgrade -y

echo "Installing pip..."
sudo apt-get install -y python-pip
sudo -H pip install --upgrade pip
sudo -H pip install numpy

echo "Installing rabbitmq..."
sudo apt-get install -y rabbitmq-server
#sudo service rabbitmq-server restart
sudo service rabbitmq-server restart

echo "Configuring rabbitmq..."
sudo rabbitmqctl add_user milo_user milo
sudo rabbitmqctl add_vhost milo_vuser
#sudo rabbitmqctl set_user_tags milo_user milotweet
sudo rabbitmqctl set_permissions -p milo_vuser milo_user ".*" ".*" ".*"

echo "Adding the SSH private key..."
echo "PRIVATE_KEY" > /home/ubuntu/.ssh/id_rsa
echo "PUBLIC KEY" > /home/ubuntu/.ssh/id_rsa.pub

echo "Installing celery..."
sudo -H pip install celery

echo "Installing flower..."
sudo -H pip install flower

# echo "Installing flask..."
# sudo -H pip install Flask

echo "Installing django..."
sudo -H pip install django

echo "Installing milo..."
cd /home/ubuntu
sudo git clone https://github.com/millovanovic/acc-c3.git
cd /home/ubuntu/acc-c3/
sudo git checkout master

echo "Setting permission"
sudo chown -R ubuntu.users /home/ubuntu/acc-c3

echo "Starting flower..."
sudo screen -S celeryserver -d -m bash -c 'celery flower -A milotweet'

echo "Starting django..."
sudo python manage.py migrate
sudo screen -S djangoserver -d -m bash -c 'python manage.py runserver 0.0.0.0:8000'

echo "Initialization complete!"
