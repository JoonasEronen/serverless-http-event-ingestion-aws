output "dynamodb_table_name" {
  description = "DynamoDB table used for raw event ingestion."
  value       = aws_dynamodb_table.events.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB events table."
  value       = aws_dynamodb_table.events.arn
}
