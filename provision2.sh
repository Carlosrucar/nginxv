# 1. Actualizar repositorios, instalar Nginx, instalar openssl
apt update
apt install -y nginx openssl

# 2. Crear la carpeta del sitio web
sudo mkdir -p /var/www/example/html

# 3. Copiar el contenido de la carpeta html a /var/www/example/html
sudo cp -r /vagrant/html/* /var/www/example/html/

# Asignar permisos adecuados
sudo chown -R www-data:www-data /var/www/example/html
sudo chmod -R 755 /var/www/example


# 5. Generar un certificado SSL autofirmado
sudo mkdir -p /etc/ssl/certs /etc/ssl/private
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/example.com.key -out /etc/ssl/certs/example.com.crt <<EOF ES Andalucía Granada IZV WEB example.com webmaster@example.com
EOF

# 6. Crear el archivo de configuración de Nginx para el sitio
sudo sh -c 'cat > /etc/nginx/sites-available/example.com <<EOL
server {
    listen 80;
    listen 443 ssl;
    server_name example.com www.example.com;
    root /var/www/example/html;
    ssl_certificate /etc/ssl/certs/example.com.crt;
    ssl_certificate_key /etc/ssl/private/example.com.key;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    location / {
        try_files uri $uri/ =404;
    }
}
EOL'

# 7. Crear enlace simbólico en sites-enabled
sudo ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/

# 8. Verificar la configuración de Nginx
sudo nginx -t

# 9. Recargar Nginx para aplicar los cambios
sudo systemctl reload nginx