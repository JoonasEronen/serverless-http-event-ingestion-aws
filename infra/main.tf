# Project 1 - Serverless HTTP Event Ingestion
#
# Build order (we will implement in this sequence):
# 1) DynamoDB table (raw events + metadata)
# 2) IAM (least privilege roles/policies)
# 3) Lambda (ingest function)
# 4) API Gateway HTTP API -> Lambda integration
# 5) CloudWatch log retention + alarms

resource "aws_dynamodb_table" "events" {
  name         = "${local.name_prefix}-events"
  billing_mode = "PAY_PER_REQUEST"

  # Primary key: each event is uniquely addressable (debug/replay)
  hash_key = "event_id"

  attribute {
    name = "event_id"
    type = "S"
  }

  # Optional: auto-expire events (disabled by default)
  ttl {
    attribute_name = "expires_at"
    enabled        = var.enable_ttl
  }

  # Optional: point-in-time recovery (disabled by default; adds cost)
  point_in_time_recovery {
    enabled = var.enable_pitr
  }

  server_side_encryption {
    enabled = true
  }
}
