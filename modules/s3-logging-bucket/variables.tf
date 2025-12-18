variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "retention_days" {
  description = "Number of days to retain logs before deletion"
  type        = number
  default     = 30
}
