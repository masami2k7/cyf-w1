output "instance_dns" {
  description = "The Public DNS for SSH Connections"
  value       = aws_instance.app_server.public_dns
}