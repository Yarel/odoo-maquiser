output "public_ip" {
  description = "Public IP of the Odoo instance"
  value       = aws_instance.odoo.public_ip
}

