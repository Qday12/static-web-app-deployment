variable "bucket_name" {
  type        = string
  default     = ""
  description = "Name for S3 bucket"
}

variable "website_index_document" {
  type        = string
  default     = "index.html"
  description = "Index document for the static website"
}

variable "website_error_document" {
  type        = string
  default     = "error.html"
  description = "Error document for the static website"
}
