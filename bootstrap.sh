#!/usr/bin/env /bin/bash

apt-get update
apt-get install -y build-essential libpam0g-dev apt-transport-https ca-certificates
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-engine

gpasswd -a vagrant docker
service docker restart

cd /tmp
git clone https://github.com/flant/pam_docker.git
cd pam_docker
make
make install-ubuntu-14.04

curl -sSL https://rvm.io/mpapis.asc | gpg --import -
curl -sSL https://get.rvm.io | sudo bash -s stable

echo 'source /etc/profile.d/rvm.sh' >> /etc/bash.bashrc
echo 'export BUNDLE_GEMFILE=/vagrant/Gemfile' >> /etc/bash.bashrc

source /etc/profile.d/rvm.sh

rvm group add rvm vagrant
rvm install 2.2.1 --quiet-curl
rvm --default use 2.2.1
gem install bundler

cd /vagrant
bundle install

cp -r /vagrant/bootstrap/* /
