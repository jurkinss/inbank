resource "aws_lightsail_instance" "inbank_ec2_instance" {
  name              = local.inbank_instance_name
  bundle_id         = "nano_2_0"
  blueprint_id      = "ubuntu_20_04"
  availability_zone = "${var.aws_region}a"
  user_data         = local.user_data_inbank
  key_pair_name     = aws_lightsail_key_pair.inbank_ec2_instance.id
  tags              = merge({ "Name" = local.inbank_instance_name }, local.tags)
}

resource "aws_lightsail_static_ip_attachment" "inbank_ec2_instance" {
  static_ip_name = aws_lightsail_static_ip.inbank_ec2_instance.id
  instance_name  = aws_lightsail_instance.inbank_ec2_instance.id
}

resource "aws_lightsail_static_ip" "inbank_ec2_instance" {
  name = "${local.inbank_instance_name}-ip"
}

resource "aws_lightsail_key_pair" "inbank_ec2_instance" {
  name       = "js"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCr464hMJ4OZZajhBFsREZWnNU+tzvNQJG/c5USqdkJSMnatfcgSxeCRDTTyFPtyqBjHf2q16GKh4eDAoW+A14AYwsolS77w/qlIEf5BhNEyQZJRy79pYWrDveyPsPdLof8yeon0wIAPi3zE7RrJQhjQ31yY97No+JzNMWbLMfrMxPZqqUbyYQE8diST95eUan6IuzDSXdgKP4oROljqNa81G+62Hk09Pi4IPGRafF8EqvmnrWI2emfAbwczhURuvNNhVO01GgPrT/ug/iwB7YjKnHNLE6gWPgZdryuLkXeRc6INgipEP7nq5jOeoVgVLPxrgXYz1l+SuCmjAdvwFUl jurijs.solovjovs@neotech.lv"
}

resource "aws_lightsail_instance_public_ports" "inbank_ec2_instance" {
  instance_name = aws_lightsail_instance.inbank_ec2_instance.name

  port_info {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
    cidrs     = data.terraform_remote_state.cloudflare.outputs.cloudflare_ip_ranges
  }
  port_info {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
    cidrs     = data.terraform_remote_state.cloudflare.outputs.cloudflare_ip_ranges
  }
  port_info {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
    cidrs     = ["217.28.48.78/32", "87.226.2.135/32"]
  }
}


locals {
  inbank_instance_name = "a-dev-inbank"

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
