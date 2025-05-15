variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}

variable "app_port" {
  description = "listner port"
  type        = number
  default     = 80
}