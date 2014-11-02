#!/usr/bin/env bash

echo ">>> Installing some useful stuff"
sudo apt-get -y upgrade
sudo apt-get install -y build-essential git git-core

curl -sL https://deb.nodesource.com/setup | sudo bash -
sudo apt-get install -y nodejs

echo ">>> Installing Yeoman"
sudo npm install -g yo

echo ">>> Installing Grunt"
sudo npm install -g grunt

echo ">>> Installing Bower"
sudo npm install -g bower

echo ">>> Installing Composer"
sudo npm install -g composer

echo ">>> Installing RVM"
curl -L https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
echo "source ~/.rvm/scripts/rvm" >> ~/.bashrc
echo "gem: --no-ri --no-rdoc" > ~/.gemrc
rvm get stable --auto
rvm reload

echo ">>> Creating the /usr/local/www/sites/ directory"
sudo mkdir /usr/local/www/
sudo ln -s /vagrant /usr/local/www/sites

echo ">>> Add Vagrant to www-data group"
sudo usermod -a -G www-data vagrant

echo ">>> Installing *.jenny.dev self-signed SSL"

SSL_DIR="/etc/ssl/jenny.dev"
DOMAIN="*.jenny.dev"
PASSPHRASE="jenny"

SUBJ="
C=US
ST=Michigan
O=DearbornHeights
localityName=Detroit
commonName=$DOMAIN
organizationalUnitName=Jenny
emailAddress=webmaster@jenny.dev
"

sudo mkdir -p "$SSL_DIR"
sudo openssl genrsa -out "$SSL_DIR/jenny.dev.key" 1024
sudo openssl req -new -subj "$(echo -n "$SUBJ" | tr "\n" "/")" -key "$SSL_DIR/jenny.dev.key" -out "$SSL_DIR/jenny.dev.csr" -passin pass:$PASSPHRASE
sudo openssl x509 -req -days 365 -in "$SSL_DIR/jenny.dev.csr" -signkey "$SSL_DIR/jenny.dev.key" -out "$SSL_DIR/jenny.dev.crt"

echo ">>> Enabling vhost alias"
sudo a2enmod vhost_alias

echo ">>> Adding jenny.dev config"
sudo curl https://gist.githubusercontent.com/nickdenardis/0863d63a2800524c3e08/raw/wayne.dev.conf | sed 's/wayne/jenny/g' > /etc/apache2/sites-available/jenny.dev.conf
sudo a2ensite jenny.dev

echo ">>> Setting up dynamic DOCUMENT_ROOT script"
sudo curl https://gist.githubusercontent.com/nickdenardis/6bc9190a9a064ea00499/raw/php_set_document_root.php | sed 's/wayne/jenny/g' > /home/vagrant/php_set_document_root.php
sudo echo "auto_prepend_file = /home/vagrant/php_set_document_root.php" >> /etc/php5/fpm/php.ini
sudo service php5-fpm restart

echo ">>> Adding *.jenny.dev config"
sudo curl https://gist.githubusercontent.com/nickdenardis/0da0cac752e60d900dd3/raw/wild-wayne.dev.conf | sed 's/wayne/jenny/g' > /etc/apache2/sites-available/wild-jenny.dev.conf

echo ">>> Enabling *.jenny.dev sites"
sudo a2ensite wild-jenny.dev

echo ">>> Reloading Apache config"
sudo service apache2 reload

echo ">>> Removing the fileMode from git tracked files"
sudo su - vagrant -c 'git config --global core.fileMode false'

echo ">>> Installing bash-it"
git clone https://github.com/revans/bash-it.git /home/vagrant/.bash_it
curl https://gist.githubusercontent.com/nickdenardis/7de0397d7c0df8c29ed3/raw/.bash_profile >> /home/vagrant/.bash_profile

echo ">>> Adding Node path to .bashrc"
echo "export NODE_PATH=$NODE_PATH:/home/vagrant/npm/lib/node_modules" >> /home/vagrant/.bashrc && source /home/vagrant/.bashrc

echo ">>> Adding vendor/bin to your path"
echo 'export PATH=vendor/bin:$PATH' >> /home/vagrant/.bashrc

echo ">>> Removing StrictHostKey Config and adding to local Vagrant Known Hosts"
rm /root/.ssh/config
sudo su - vagrant -c 'ssh-keyscan -H github.com >> /home/vagrant/.ssh/known_hosts'
sudo su - vagrant -c 'ssh-keyscan -H bitbucket.org >> /home/vagrant/.ssh/known_hosts'

echo ">>> Installing SASS CSS Importer"
sudo su - vagrant -c 'gem install --pre sass-css-importer'

echo ">>> Installing newest Virtual Box Additions"
wget http://download.virtualbox.org/virtualbox/4.3.16/VBoxGuestAdditions_4.3.16.iso
sudo mkdir /media/VBoxGuestAdditions
sudo mount -o loop,ro VBoxGuestAdditions_4.3.16.iso /media/VBoxGuestAdditions
sudo sh /media/VBoxGuestAdditions/VBoxLinuxAdditions.run
rm VBoxGuestAdditions_4.3.16.iso
sudo umount /media/VBoxGuestAdditions
sudo rmdir /media/VBoxGuestAdditions
