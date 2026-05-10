output "instance_ids" {
  description = "List of EC2 instance IDs"
  value       = aws_instance.this[*].id
}

output "instance_private_ips" {
  description = "List of private IP addresses"
  value       = aws_instance.this[*].private_ip
}

output "security_group_id" {
  description = "Security group ID for the instances"
  value       = aws_security_group.instance.id
}
