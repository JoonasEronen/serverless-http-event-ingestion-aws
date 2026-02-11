terraform {
  backend "s3" {
    bucket         = "tfstate-joonaseronen-eu-north-1"
    key            = "serverless-http-event-ingestion-aws/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
