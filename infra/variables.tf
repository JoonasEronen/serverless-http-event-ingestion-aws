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
