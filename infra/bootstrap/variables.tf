variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "tfstate_bucket_name" {
  type = string
}

variable "lock_table_name" {
  type    = string
  default = "terraform-locks"
}

variable "tags" {
  type = map(string)
  default = {
    Project     = "serverless-http-event-ingestion-aws"
    ManagedBy   = "Terraform"
    Environment = "prod"
  }
}
