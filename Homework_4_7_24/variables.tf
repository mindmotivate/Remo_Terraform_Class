# Define Variables
variable "document_storage_bucket_name" {
  description = "Name of the S3 bucket used for storing documents."
  type        = string
  default     = "document-storage-bucket987"
}

variable "logs_bucket_name" {
  description = "Name of the S3 bucket used for storing logs."
  type        = string
  default     = "logs-bucket654"
}

variable "document_access_role_name" {
  description = "Name of the IAM role with read-write access to the document storage bucket."
  type        = string
  default     = "document-access-role"
}

variable "logs_access_role_name" {
  description = "Name of the IAM role with read-only access to the logs bucket."
  type        = string
  default     = "logs-access-role"
}
