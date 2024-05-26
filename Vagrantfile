Vagrant.configure("2") do |config|
  config.vm.box = "bento/debian-12"
  config.vm.provider "vmware_desktop" do |v|
    v.vmx["memsize"] = "1024"
    v.vmx["numvcpus"] = "2"
    v.vmx["displayName"] = "VM_GLPI"
    
    
     config.vm.network "public_network", ip: "192.168.1.52"
  end
  config.vm.provision "shell", inline: <<-SHELL
 #Mettez à jour la liste des paquets et les paquets eux-mêmes 
  sudo -i
 apt-get update && apt-get upgrade
 #Installez Apache2
 apt-get install apache2 php libapache2-mod-php
#Installez PHP
 apt-get install php-imap php-ldap php-curl php-xmlrpc php-gd php-mysql php-cas
 #Installez MariaDB
 apt-get install mariadb-server
 mysql_secure_installation
 #Installez les modules complémentaires au bon fonctionnement de GLPI et de MariaDB
 sudo apt-get install php-xml php-common php-json php-mysql php-mbstring php-curl php-gd php-intl php-zip php-bz2 php-imap php-apcu
 #Redémarrez les services
 /etc/init.d/apache2 restart
 /etc/init.d/mysql restart
 #Créez la base de données qui nous permettra ensuite d’installer GLPI
 mysql -u root -p
 create database glpidb; 
 grant all privileges on glpidb.* to glpiuser@localhost identified by "P@ssword";
 quit
# Installez phpmyadmin
 apt-get install phpmyadmin
 #Installez GLPI
 cd /tmp
 wget https://github.com/glpi-project/glpi/releases/download/10.0.15/glpi-10.0.15.tgz
 tar -zxvf glpi-10.0.15.tgz
 chown www-data /var/www/glpi/ -R
 mkdir /etc/glpi
 chown www-data /etc/glpi/
 mv /var/www/glpi/config /etc/glpi
 mkdir /var/lib/glpi
 chown www-data /var/lib/glpi/
 mv /var/www/glpi/files /var/lib/glpi
 mkdir /var/log/glpi
 chown www-data /var/log/glpi
 # Créer les fichiers de configuration de GLPI
 cat > /var/www/glpi/inc/downstream.php << EOF
 <?php
define('GLPI_CONFIG_DIR', '/etc/glpi/');
if (file_exists(GLPI_CONFIG_DIR . '/local_define.php')) {
    require_once GLPI_CONFIG_DIR . '/local_define.php';
}
EOF
cat > /etc/glpi/local_define.php << EOF
<?php
define('GLPI_VAR_DIR', '/var/lib/glpi/files');
define('GLPI_LOG_DIR', '/var/log/glpi');
EOF
cat > /etc/apache2/sites-available/000-default.conf << EOF
<VirtualHost *:80>
       DocumentRoot /var/www/html/glpi/public  
       <Directory /var/www/html/glpi/public>
                Require all granted
                RewriteEngine On
                RewriteCond %{REQUEST_FILENAME} !-f
                RewriteRule ^(.*)$ index.php [QSA,L]
        </Directory>
        
        LogLevel warn
        ErrorLog \${APACHE_LOG_DIR}/error-glpi.log
        CustomLog \${APACHE_LOG_DIR}/access-glpi.log combined
        
</VirtualHost>
EOF
a2ensite 000-default
a2enmod rewrite
/etc/init.d/apache2 restart
apt-get install php8.2-fpm
a2enmod proxy_fcgi setenvif
a2enconf php8.2-fpm
systemctl reload apache2
cat > /etc/php/8.2/fpm/php.ini << EOF
; Whether or not to add the httpOnly flag to the cookie, which makes it
; inaccessible to browser scripting languages such as JavaScript.
; https://php.net/session.cookie-httponly
session.cookie_httponly = on
EOF
systemctl restart php8.2-fpm.service
# Pour finir, nous devons modifier notre VirtualHost pour préciser à Apache2 que PHP-FPM doit être utilisé pour les fichiers PHP
# et que les sessions doivent être stockées dans un dossier PHP-FPM.
 systemctl restart apache2

  SHELL
end