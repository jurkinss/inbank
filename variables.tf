variable "aws_region" {
  default = "eu-west-2"
}
variable "NGINX_CONF" {}

variable "CF_CERTIFICATE" {
  sensitive   = true
}
variable "CF_PRIVATE_KEY" {
  sensitive   = true
}
