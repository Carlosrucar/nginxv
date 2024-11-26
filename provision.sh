# 1. Actualizar repositorios, instalar Nginx, instalar git para traer el repositorio
apt update
apt install -y nginx git vsftpd

# Verificar que Nginx esté funcionando
sudo systemctl status nginx

# 2. Crear la carpeta del sitio web
sudo mkdir -p /var/www/miweb/html

# Clonar el repositorio de ejemplo en la carpeta del sitio web
git clone https://github.com/cloudacademy/static-website-example /var/www/miweb/html

# Asignar permisos adecuados
sudo chown -R www-data:www-data /var/www/miweb/html
sudo chmod -R 755 /var/www/miweb

# 3. Configurar Nginx para servir el sitio web
# Crear archivo de configuración del sitio en sites-available
cat <<EOL | sudo tee /etc/nginx/sites-available/miweb
server {
    listen 80;
    server_name www.carlos.test;

    root /var/www/miweb/html;
    index index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOL

# Crear enlace simbólico en sites-enabled
sudo ln -s /etc/nginx/sites-available/miweb /etc/nginx/sites-enabled/

# Crear usuario carlos
sudo adduser carlos
echo "carlos:carlos" | sudo chpasswd

# Crea la carpeta
sudo mkdir /home/carlos/ftp

# Permisos para la carpeta
sudo chown vagrant:vagrant /home/carlos/ftp
sudo chmod 755 /home/carlos/ftp

cp /vagrant/vsftpd.conf /etc/vsftpd.conf

# Crear los certificados de seguridad
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.key -out /etc/ssl/certs/vsftpd.crt

# Agregar el usuario carlos al grupo www-data
sudo usermod -aG www-data carlos

# Crear la nueva carpeta de la página web
sudo mkdir -p /var/www/extrem/html

# Asignar permisos
sudo chown -R www-data:carlos /var/www/
sudo chmod -R 775 /var/www/

# Crear archivo de configuración del sitio extrem
cat <<EOL | sudo tee /etc/nginx/sites-available/extrem
server {
    listen 80;
    server_name extremweb.test;

    root /var/www/extrem/html;
    index index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOL

# Crear enlace simbólico en sites-enabled
sudo ln -s /etc/nginx/sites-available/extrem /etc/nginx/sites-enabled/

# Verificar la configuración de Nginx
sudo nginx -t

# Reiniciar Nginx para aplicar los cambios
sudo systemctl restart nginx

#!/bin/bash

# 1. Actualizar repositorios e instalar Nginx y openssl
apt update
apt install -y nginx openssl

# 2. Crear la carpeta del sitio web
sudo mkdir -p /var/www/nuevo_sitio/html

# 3. Copiar el contenido de la carpeta html a /var/www/nuevo_sitio/html
sudo cp -r /vagrant/html/* /var/www/nuevo_sitio/html/

# Asignar permisos adecuados
sudo chown -R www-data:www-data /var/www/nuevo_sitio/html
sudo chmod -R 755 /var/www/nuevo_sitio

# 4. Crear usuarios y contraseñas para el acceso web
sudo sh -c "echo -n 'carlos:' >> /etc/nginx/.htpasswd"
sudo sh -c "openssl passwd -apr1 '9443' >> /etc/nginx/.htpasswd"
sudo sh -c "echo -n 'Rodriguez:' >> /etc/nginx/.htpasswd"
sudo sh -c "openssl passwd -apr1 '9443' >> /etc/nginx/.htpasswd"

# 5. Configurar Nginx para usar autenticación básica
cat <<EOL | sudo tee /etc/nginx/sites-available/nuevo_sitio
server {
    listen 80;
    listen [::]:80;
    root /var/www/nuevo_sitio/html;
    index index.html index.htm;
    server_name nuevo_sitio.test;

    location / {
        auth_basic "Área restringida";
        auth_basic_user_file /etc/nginx/.htpasswd;
        try_files $uri $uri/ =404;
    }
}
EOL

# 6. Crear enlace simbólico en sites-enabled
sudo ln -s /etc/nginx/sites-available/nuevo_sitio /etc/nginx/sites-enabled/

# 7. Reiniciar Nginx para aplicar los cambios
sudo systemctl restart nginx

# 8. Configurar Nginx para denegar acceso desde la IP de la máquina anfitriona
cat <<EOL | sudo tee /etc/nginx/sites-available/nuevo_sitio
server {
    listen 80;
    listen [::]:80;
    root /var/www/nuevo_sitio/html;
    index index.html index.htm;
    server_name nuevo_sitio.test;

    location / {
        deny 192.168.32.1;
        allow all;
        auth_basic "Área restringida";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
}
EOL

# 9. Reiniciar Nginx para aplicar los cambios
sudo systemctl restart nginx

# 10. Configurar Nginx para requerir tanto una IP válida como un usuario válido
cat <<EOL | sudo tee /etc/nginx/sites-available/nuevo_sitio
server {
    listen 80;
    listen [::]:80;
    root /var/www/nuevo_sitio/html;
    index index.html index.htm;
    server_name nuevo_sitio.test;

    location / {
        satisfy all;
        deny 192.168.32.1;
        allow 192.168.32.0/24;
        auth_basic "Área restringida";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
}
EOL

# 11. Reiniciar Nginx para aplicar los cambios
sudo systemctl restart nginx

