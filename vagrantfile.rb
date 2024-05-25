Vagrant.configure("2") do |config|
  config.vm.box = "bento/debian-12"
  config.vm.provider "vmware_desktop vmware_fusion vmware_workstation (x64)" do |v|
  config.vm.network "public_network", ip: "192.168.1.52"
    v.vmx["memsize"] = "2048"
    v.vmx["numvcpus"] = "2"
    
  end
  config.vm.provision "shell", inline: <<-SHELL
  # set french keyboard
  loadkeys fr
  #install LAMP
  sudo apt update
  # install LAMP
  sudo apt-get install apache2 php mariadb-server
  # installer toutes les extensions nécessaires au bon fonctionnement de GLPI.
  sudo apt install -y php libapache2-mod-php php-mysql 
  sudo apt install php-mysql php-mbstring php-curl php-gd php-xml php-intl php-ldap php-apcu php-xmlrpc php-zip php-bz2 php-imap -y
  sudo systemctl restart apache2
  # base de données pour GLPI
  sudo mysql_secure_installation
  sudo mysql -u root -p
  CREATE DATABASE db12_glpi;
  GRANT ALL PRIVILEGES ON db12_glpi.* TO glpi_adm@'192.168.1.52' IDENTIFIED BY "glpipass";
  FLUSH PRIVILEGES;
  EXIT
  # install glpi on debian
  sudo apt install -y wget
  sudo wget https://github.com/glpi-project/glpi/releases/download/10.0.7/glpi-10.0.7.tgz
  sudo tar -zxvf glpi-10.0.7.tgz
  sudo mv glpi /var/www/html/
# Configuration des emplacements des dossiers et fichiers de GLPI
  sudo mkdir /etc/glpi
  sudo nano /etc/glpi/local_define.php
  # inserer les informations suivantes puis enregistrer avec CTRL+O puis CTRL+X
  <?php
  define('GLPI_VAR_DIR', '/var/lib/glpi');
  define('GLPI_LOG_DIR', '/var/log/glpi');
  #Déplacez le dossier « config » situé actuellement dans /var/www/html/glpi dans /etc/glpi 
  sudo mv /var/www/html/glpi/config /etc/glpi
  sudo chown -R www-data /etc/glpi/
  sudo mv /var/www/html/glpi/files /var/lib/glpi
  sudo chmod -R 755 /etc/glpi/
  sudo mkdir /var/log/glpi
  sudo chown www-data /var/log/glpi
  sudo nano /var/www/html/glpi/inc/downstream.php
 # y inserer les informations suivantes puis enregistrer avec CTRL+O puis CTRL+X
<?php
define('GLPI_CONFIG_DIR', '/etc/glpi/');
if (file_exists(GLPI_CONFIG_DIR . '/local_define.php')) {
require_once GLPI_CONFIG_DIR . '/local_define.php';
}
# Configuration du service web apache2 pour utiliser le dossier /var/www/html/glpi
  sudo nano /etc/php/8.2/apache2/php.ini
 # recherchez la ligne « session.cookie_httponly  = » et ajoutez « on » après le égal
 # 
 sudo nano /etc/apache2/sites-available/glpi.conf
# Y insérer le contenu suivant basé sur la doc GLPI, une fois encore en adaptant à votre environnement
# y insérer le contenu suivant puis enregistrer avec CTRL+O puis CTRL+X 
<VirtualHost *:80>
ServerName vm-glpi
ServerAlias 192.168.3.80
DocumentRoot /var/www/html
Alias "/glpi" "/var/www/html/glpi/public"
<Directory /var/www/html/glpi>
Require all granted
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^(.*)$ index.php [QSA,L]
</Directory>
</VirtualHost>
# enable rewrite for glpi.conf 
sudo systemctl restart apache2
sudo a2enmod rewrite
sudo a2ensite glpi.conf
sudo systemctl reload apache2
# configure rules for glpi in apache
sudo nano /etc/apache2/sites-available/000-default.conf
sudo sed -i "s|<Directory />|<Directory /var/www/html/glpi/public>|" /etc/apache2/sites-available/000-default.conf
sudo sed -i "s|AllowOverride None|AllowOverride All|" /etc/apache2/sites-available/000-default.conf
sudo systemctl restart apache2
  SHELL
end
