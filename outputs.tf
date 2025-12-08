output "public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.web_server.public_ip
}

output "website_url" {
  description = "The public URL to access the website"
  value       = "http://${aws_instance.web_server.public_ip}"
}