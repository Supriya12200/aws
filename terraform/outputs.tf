output "primary_record_fqdn" {
  description = "Primary Route 53 record FQDN."
  value       = module.route53_failover.primary_record_fqdn
}

output "secondary_record_fqdn" {
  description = "Secondary Route 53 record FQDN."
  value       = module.route53_failover.secondary_record_fqdn
}

output "primary_health_check_id" {
  description = "Primary Route 53 health check ID."
  value       = module.route53_failover.primary_health_check_id
}

output "secondary_health_check_id" {
  description = "Secondary Route 53 health check ID."
  value       = module.route53_failover.secondary_health_check_id
}

output "cloudwatch_alarm_arn" {
  description = "CloudWatch alarm ARN when enabled."
  value       = module.route53_failover.cloudwatch_alarm_arn
}

output "sns_topic_arn" {
  description = "SNS topic ARN when created."
  value       = module.route53_failover.sns_topic_arn
}
