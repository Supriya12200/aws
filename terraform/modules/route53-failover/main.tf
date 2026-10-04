resource "aws_route53_health_check" "primary" {
  fqdn              = var.primary_endpoint
  port              = var.health_check_port
  type              = var.health_check_type
  resource_path     = var.health_check_path
  request_interval  = var.request_interval
  failure_threshold = var.failure_threshold

  tags = merge(var.tags, {
    Name = "${var.record_name}-primary-health"
    Role = "primary"
  })
}

resource "aws_route53_health_check" "secondary" {
  fqdn              = var.secondary_endpoint
  port              = var.health_check_port
  type              = var.health_check_type
  resource_path     = var.health_check_path
  request_interval  = var.request_interval
  failure_threshold = var.failure_threshold

  tags = merge(var.tags, {
    Name = "${var.record_name}-secondary-health"
    Role = "secondary"
  })
}

resource "aws_route53_record" "primary" {
  zone_id = var.hosted_zone_id
  name    = var.record_name
  type    = var.record_type
  ttl     = var.ttl

  set_identifier = "primary"

  failover_routing_policy {
    type = "PRIMARY"
  }

  health_check_id = aws_route53_health_check.primary.id

  records = [var.primary_endpoint]
}

resource "aws_route53_record" "secondary" {
  zone_id = var.hosted_zone_id
  name    = var.record_name
  type    = var.record_type
  ttl     = var.ttl

  set_identifier = "secondary"

  failover_routing_policy {
    type = "SECONDARY"
  }

  health_check_id = aws_route53_health_check.secondary.id

  records = [var.secondary_endpoint]
}

resource "aws_sns_topic" "health" {
  count = var.enable_cloudwatch_alarm && var.create_sns_topic ? 1 : 0

  name = "${replace(var.record_name, ".", "-")}-route53-health"
  tags = var.tags
}

resource "aws_sns_topic_subscription" "email" {
  count = var.enable_cloudwatch_alarm && var.create_sns_topic && var.alarm_email != null ? 1 : 0

  topic_arn = aws_sns_topic.health[0].arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

resource "aws_cloudwatch_metric_alarm" "primary_health" {
  count = var.enable_cloudwatch_alarm ? 1 : 0

  alarm_name          = "${var.record_name}-primary-route53-health"
  alarm_description   = "Primary Route 53 health check is unhealthy."
  namespace           = "AWS/Route53"
  metric_name         = "HealthCheckStatus"
  statistic           = "Minimum"
  period              = var.alarm_period
  evaluation_periods  = var.alarm_evaluation_periods
  threshold           = var.alarm_threshold
  comparison_operator = "LessThanThreshold"

  dimensions = {
    HealthCheckId = aws_route53_health_check.primary.id
  }

  treat_missing_data = "breaching"

  alarm_actions = var.create_sns_topic ? [aws_sns_topic.health[0].arn] : []

  tags = merge(var.tags, {
    Name = "${var.record_name}-primary-health-alarm"
  })
}
