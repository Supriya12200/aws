module "route53_failover" {
  source = "./modules/route53-failover"

  hosted_zone_id       = var.hosted_zone_id
  record_name          = var.record_name
  record_type          = var.record_type
  primary_endpoint     = var.primary_endpoint
  secondary_endpoint   = var.secondary_endpoint
  health_check_type    = var.health_check_type
  health_check_path    = var.health_check_path
  health_check_port    = var.health_check_port
  health_check_protocol = var.health_check_protocol
  request_interval     = var.request_interval
  failure_threshold    = var.failure_threshold
  ttl                  = var.ttl
  enable_cloudwatch_alarm = var.enable_cloudwatch_alarm
  create_sns_topic     = var.create_sns_topic
  alarm_email          = var.alarm_email
  alarm_period         = var.alarm_period
  alarm_evaluation_periods = var.alarm_evaluation_periods
  alarm_threshold      = var.alarm_threshold
  tags                 = var.tags
}
