#!/bin/bash
# Install Docker on Amazon Linux 2

set -x

# Update package index
sudo yum update -y

# Install Docker
sudo yum install -y docker

# Start Docker service
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker

# Add ec2-user to the docker group
sudo usermod -aG docker ec2-user

# Install docker compose
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) \
  -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose

# Download the docker-compose.yml file for wg-easy
curl https://raw.githubusercontent.com/chelobaeza/wireguard-vpn-terraform/refs/heads/main/compose.yml -o compose.yml

# Start wg-easy using Docker Compose
docker compose --project-name vpn up -d

# Nginx configuration
sudo yum install -y nginx
sudo yum install -y nss-tools

# Install mkcert for local TLS certificates
PUBLIC_IP=$(curl -s ifconfig.me)
echo "Public IP: $PUBLIC_IP"

echo "Downloading mkcert..."
curl -JLO https://dl.filippo.io/mkcert/latest?for=linux/amd64
chmod +x mkcert-*
sudo mv mkcert-* /usr/local/bin/mkcert


echo "Installing mkcert..."
export CAROOT="/etc/ssl/mkcert"
mkdir -p "$CAROOT"
mkcert -install
mkcert $PUBLIC_IP
echo "Certificates generated for $PUBLIC_IP"
CRT_FILE=$(ls *.pem | grep -v key)
KEY_FILE=$(ls *-key.pem)
echo "Certificate file: $CRT_FILE"
echo "Key file: $KEY_FILE"

echo "Copying certificates to /etc/ssl/local"
sudo mkdir -p /etc/ssl/local
sudo cp $CRT_FILE /etc/ssl/local/cert.pem
sudo cp $KEY_FILE /etc/ssl/local/key.pem
echo "Certificates copied to /etc/ssl/local"


# Configure Nginx to proxy requests to wg-easy
cat <<EOF | sudo tee /etc/nginx/conf.d/wireguard.conf > /dev/null
server {
    listen 443 ssl;

    ssl_certificate /etc/ssl/local/cert.pem;
    ssl_certificate_key /etc/ssl/local/key.pem;

    location / {
        proxy_pass http://localhost:51821;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

sudo nginx -t
sudo systemctl enable nginx
sudo systemctl restart nginx

set +x