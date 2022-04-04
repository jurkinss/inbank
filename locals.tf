locals {
  aws_profile          = "inbank"
  inbank_instance_name = "a-devinbank"

  user_data_inbank = <<EOT
#!/bin/bash
apt-get update -y
apt-get install ca-certificates curl gnupg lsb-release unzip -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io -y
systemctl enable docker
usermod -a -G docker ubuntu
apt-get install nginx -y
systemctl enable nginx
echo "${var.CF_CERTIFICATE}" > /etc/nginx/server.crt
echo "${var.CF_PRIVATE_KEY} "> /etc/nginx/server.key
docker run -d -p 51821:3000 bkimminich/juice-shop
rm -rf /etc/nginx/nginx.conf
echo "${var.NGINX_CONF}" > /etc/nginx/nginx.conf
systemctl restart nginx

EOT

}
