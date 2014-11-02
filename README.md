Vagrants
========
Before you clone this and run it, install the following Vagrant plugin<br>
<br>
The plugin manages installing/configuring virtualbox guest additions for you<br>
<b>
vagrant plugin install vagrant-vbguest
</b>
<br>
Run the following line to add an entry to your hosts file so you can access the server<br>
<b>
sudo echo "192.168.22.10 jenny.dev" >> /etc/hosts
</b>
<br>
Your web root on the vagrant vm will be<br>
<b>
/usr/local/www/sites/jenny/sites
</b>
<br>
which is aliased to
<br>
<b>
/vagrant/sites
</b>
<br>
which resides whereever you cloned this repo/jennydev/sites
