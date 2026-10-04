variable "aws_region" {
  description = "AWS region used by the provider and CloudWatch/SNS resources."
  type        = string
  default     = "ap-south-1"
}

variable "hosted_zone_id" {
  description = "Existing public Route 53 hosted zone ID."
  type        = string
}

variable "record_name" {
  description = "DNS name for the failover record."
  type        = string
}

variable "record_type" {
  description = "DNS record type."
  type        = string
  default     = "A"
}

variable "primary_endpoint" {
  description = "Primary endpoint hostname or IPv4 address used by the Route 53 health check."
  type        = string
}

variable "secondary_endpoint" {
  description = "Secondary endpoint hostname or IPv4 address used by the Route 53 health check."
  type        = string
}

variable "health_check_type" {
  description = "Route 53 health check type: HTTP, HTTPS, HTTP_STR_MATCH, HTTPS_STR_MATCH, TCP."
  type        = string
  default     = "HTTPS"
}

variable "health_check_path" {
  description = "Path checked by HTTP/HTTPS health checks."
  type        = string
  default     = "/health"
}

variable "health_check_port" {
  description = "Health-check port."
  type        = number
  default     = 443
}

variable "health_check_protocol" {
  description = "Health-check protocol label used for configuration clarity."
  type        = string
  default     = "HTTPS"
}

variable "request_interval" {
  description = "Health check request interval in seconds. Route 53 supports 10 or 30."
  type        = number
  default     = 30
}

variable "failure_threshold" {
  description = "Number of consecutive failures before the health check is considered unhealthy."
  type        = number
  default     = 3
}

variable "ttl" {
  description = "TTL in seconds for the failover records."
  type        = number
  default     = 30
}

variable "enable_cloudwatch_alarm" {
  description = "Create a CloudWatch alarm for the primary Route 53 health check."
  type        = bool
  default     = true
}

variable "create_sns_topic" {
  description = "Create an SNS topic and optional email subscription for the health alarm."
  type        = bool
  default     = false
}

variable "alarm_email" {
  description = "Optional email address for SNS subscription. Requires confirmation."
  type        = string
  default     = null
  nullable    = true
}

variable "alarm_period" {
  description = "CloudWatch alarm period in seconds."
  type        = number
  default     = 60
}

variable "alarm_evaluation_periods" {
  description = "Number of CloudWatch evaluation periods."
  type        = number
  default     = 2
}

variable "alarm_threshold" {
  description = "HealthCheckStatus threshold for the alarm."
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags applied to supported AWS resources."
  type        = map(string)
  default = {
    Project   = "route53-failover"
    ManagedBy = "Terraform"
  }
}
