output "primary_record_fqdn" {
  value = aws_route53_record.primary.fqdn
}

output "secondary_record_fqdn" {
  value = aws_route53_record.secondary.fqdn
}

output "primary_health_check_id" {
  value = aws_route53_health_check.primary.id
}

output "secondary_health_check_id" {
  value = aws_route53_health_check.secondary.id
}

output "cloudwatch_alarm_arn" {
  value = try(aws_cloudwatch_metric_alarm.primary_health[0].arn, null)
}

output "sns_topic_arn" {
  value = try(aws_sns_topic.health[0].arn, null)
}
