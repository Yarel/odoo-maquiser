variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  description = "Nombre del par de claves SSH"
  default     = "odoo"
}

variable "public_key_path" {
  description = "Ruta al archivo .pub de tu llave SSH"
  default     = "~/.ssh/id_rsa.pub"
}

