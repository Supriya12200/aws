variable "hosted_zone_id" {
  type = string
}

variable "record_name" {
  type = string
}

variable "record_type" {
  type    = string
  default = "A"
}

variable "primary_endpoint" {
  type = string
}

variable "secondary_endpoint" {
  type = string
}

variable "health_check_type" {
  type    = string
  default = "HTTPS"
}

variable "health_check_path" {
  type    = string
  default = "/health"
}

variable "health_check_port" {
  type    = number
  default = 443
}

variable "health_check_protocol" {
  type    = string
  default = "HTTPS"
}

variable "request_interval" {
  type    = number
  default = 30
}

variable "failure_threshold" {
  type    = number
  default = 3
}

variable "ttl" {
  type    = number
  default = 30
}

variable "enable_cloudwatch_alarm" {
  type    = bool
  default = true
}

variable "create_sns_topic" {
  type    = bool
  default = false
}

variable "alarm_email" {
  type      = string
  default   = null
  nullable  = true
}

variable "alarm_period" {
  type    = number
  default = 60
}

variable "alarm_evaluation_periods" {
  type    = number
  default = 2
}

variable "alarm_threshold" {
  type    = number
  default = 1
}

variable "tags" {
  type    = map(string)
  default = {}
}
