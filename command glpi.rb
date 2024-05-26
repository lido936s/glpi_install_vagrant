config.vm.provision "shell", inline: <<-SHELL
sudo -i
  # set french keyboard
  loadkeys fr
  # install update
  apt update
  # install LAMP
  apt-get install apache2 php mariadb-server
  # installer toutes les extensions nécessaires au bon fonctionnement de GLPI.
  apt install -y php libapache2-mod-php php-mysql 
  apt install php-mbstring php-curl php-gd php-xml php-intl php-ldap php-apcu php-xmlrpc php-zip php-bz2 php-imap -y
  systemctl restart apache2
  # base de données pour GLPI
  mysql_secure_installation
  mysql -u root -p
  touch glpi.sql
  echo "create database glpidb;" >> glpi.sql
  echo "grant all privileges on glpidb.* to glpiuser@'localhost' identified by \"root\";" >> glpi.sql
  mysql < glpi.sql
  rm glpi.sql
  # install glpi on debian
  apt install -y wget
  wget https://github.com/glpi-project/glpi/releases/download/10.0.7/glpi-10.0.7.tgz
  tar -zxvf glpi-10.0.7.tgz
  mv glpi /var/www/html/
  # Configuration des emplacements des dossiers et fichiers de GLPI
  mkdir /etc/glpi
  #nano /etc/glpi/local_define.php
  # inserer les informations suivantes puis enregistrer avec CTRL+O puis CTRL+X
  #<?php
  #define('GLPI_VAR_DIR', '/var/lib/glpi');
  #define('GLPI_LOG_DIR', '/var/log/glpi');
  # Déplacez le dossier « config » situé actuellement dans /var/www/html/glpi dans /etc/glpi 
  mv /var/www/html/glpi/config /etc/glpi
  chown -R www-data /etc/glpi/
  mv /var/www/html/glpi/files /var/lib/glpi
  chmod -R 755 /etc/glpi/
  mkdir /var/log/glpi
  chown www-data /var/log/glpi
  #nano /var/www/html/glpi/inc/downstream.php
  # y inserer les informations suivantes puis enregistrer avec CTRL+O puis CTRL+X
  #<?php
  #define('GLPI_CONFIG_DIR', '/etc/glpi/');
  #if (file_exists(GLPI_CONFIG_DIR . '/local_define.php')) {
  # require_once GLPI_CONFIG_DIR . '/local_define.php';
  #}
  # Configuration du service web apache2 pour utiliser le dossier /var/www/html/glpi
  #nano /etc/php/8.2/apache2/php.ini
 # recherchez la ligne « session.cookie_httponly  = » et ajoutez « on » après le égal
 #nano /etc/apache2/sites-available/glpi.conf
# y insérer le contenu suivant puis enregistrer avec CTRL+O puis CTRL+X 
echo -e "<VirtualHost *:80>\n\tDocumentRoot /var/www/html/glpi\n\n\t<Directory /var/www/html/glpi>\n\t\tAllowOverride All\n\t\tOrder Allow,Deny\n\t\tAllow from all\n\t</Directory>\n\n\tErrorLog /var/log/apache2/error-glpi.log\n\tLogLevel warn\n\tCustomLog /var/log/apache2/access-glpi.log combined\n</VirtualHost>" > /etc/apache2/sites-available/000-default.conf
# enable rewrite for glpi.conf 
systemctl restart apache2
a2enmod rewrite
a2ensite glpi.conf
systemctl reload apache2
# configure rules for glpi in apache
#nano /etc/apache2/sites-available/000-default.conf
touch /etc/apache2/sites-available/glpi.conf
sed -i "s|<Directory />|<Directory /var/www/html/glpi/public>|" /etc/apache2/sites-available/000-default.conf
sed -i "s|AllowOverride None|AllowOverride All|" /etc/apache2/sites-available/000-default.conf
systemctl restart apache2
SHELL
end