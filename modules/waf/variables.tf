variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "rate_limit" {
  description = "Maximum requests per 5-minute window per IP (100/min = 500)"
  type        = number
  default     = 500
}
