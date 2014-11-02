#!/usr/bin/env bash
echo
echo ">>> Installing some useful stuff"
sudo apt-get -y upgrade
sudo apt-get install -y build-essential git git-core
curl -sL https://deb.nodesource.com/setup | sudo bash -
sudo apt-get install -y nodejs

echo
echo ">>> Installing Yeoman"
sudo npm install -g yo

echo
echo ">>> Installing Grunt"
sudo npm install -g grunt

echo
echo ">>> Installing Bower"
sudo npm install -g bower

echo
echo ">>> Installing Composer"
sudo npm install -g composer

echo
echo ">>> Installing RVM"
curl -L https://get.rvm.io | bash -s stable
source /home/vagrant/.rvm/scripts/rvm
echo "source /home/vagrant/.rvm/scripts/rvm" >> /home/vagrant/.bashrc
echo "gem: --no-ri --no-rdoc" > /home/vagrant/.gemrc
sudo su - vagrant -c "rvm get stable --auto"
sudo su - vagrant -c "rvm reload"

echo
echo ">>> Creating the /usr/local/www/sites/ directory"
sudo mkdir -p /usr/local/www/sites/jenny
sudo ln -s /vagrant /usr/local/www/sites/jenny

echo
echo ">>> Add Vagrant to www-data group"
sudo usermod -a -G www-data vagrant

echo
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

echo
echo ">>> Enabling vhost alias"
sudo a2enmod vhost_alias

echo
echo ">>> Adding jenny.dev config"
sudo curl https://raw.githubusercontent.com/pgporada/Vagrants/master/jennydev/apache/jenny.dev.conf  > /etc/apache2/sites-available/jenny.dev.conf
sudo a2ensite jenny.dev
sudo service apache2 restart

echo
echo ">>> Removing the fileMode from git tracked files"
sudo su - vagrant -c 'git config --global core.fileMode false'

echo
echo ">>> Installing dotfiles and bash_it"
sudo su - vagrant -c "git clone https://github.com/revans/bash-it.git /home/vagrant/.bash_it"
sudo su - vagrant -c "curl https://raw.githubusercontent.com/pgporada/Vagrants/master/jennydev/dotfiles/.bash_profile > /home/vagrant/.bash_profile"
sudo su - vagrant -c "mkdir -p ~/.vim/colors"
sudo su - vagrant -c "curl https://raw.githubusercontent.com/pgporada/Vagrants/master/jennydev/dotfiles/.vim/colors/inkpot.vim > /home/vagrant/.vim/colors/inkpot.vim"
sudo su - vagrant -c "curl https://raw.githubusercontent.com/pgporada/Vagrants/master/jennydev/dotfiles/.vimrc > /home/vagant/.vimrc"


echo
echo ">>> Adding Node path to .bashrc"
echo "export NODE_PATH=$NODE_PATH:/home/vagrant/npm/lib/node_modules" >> /home/vagrant/.bashrc && source /home/vagrant/.bashrc
echo
echo ">>> Adding vendor/bin to your path"
sudo su - vagrant -c "echo 'export PATH=vendor/bin:$PATH' >> /home/vagrant/.bashrc"
echo
echo ">>> Removing StrictHostKey Config and adding to local Vagrant Known Hosts"
rm -f /root/.ssh/config
sudo su - vagrant -c 'ssh-keyscan -H github.com >> /home/vagrant/.ssh/known_hosts'
sudo su - vagrant -c 'ssh-keyscan -H bitbucket.org >> /home/vagrant/.ssh/known_hosts'

echo
echo ">>> Installing SASS CSS Importer"
sudo su - vagrant -c "gem install --user-install --pre sass-css-importer"

#echo
#echo ">>> Installing newest Virtual Box Additions"
#curl -O  http://download.virtualbox.org/virtualbox/4.3.16/VBoxGuestAdditions_4.3.16.iso
#sudo mkdir -p /media/VBoxGuestAdditions
#sudo mount -o loop,ro VBoxGuestAdditions_4.3.16.iso /media/VBoxGuestAdditions
#sudo sh /media/VBoxGuestAdditions/VBoxLinuxAdditions.run
#rm -f VBoxGuestAdditions_4.3.16.iso
#sudo umount /media/VBoxGuestAdditions
#sudo rmdir /media/VBoxGuestAdditions
