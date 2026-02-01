variable "project" {
  description = "Project name used in tags and resource naming."
  type        = string
  default     = "aws-event-ingestion"
}

variable "env" {
  description = "Environment name (dev/stage/prod)."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "eu-north-1"
}

variable "enable_ttl" {
  description = "Enable DynamoDB TTL to auto-expire events."
  type        = bool
  default     = false
}

variable "enable_pitr" {
  description = "Enable Point-in-Time Recovery for the DynamoDB table (extra cost)."
  type        = bool
  default     = false
}
