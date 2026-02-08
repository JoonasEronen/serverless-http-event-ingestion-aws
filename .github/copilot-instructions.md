# AI Coding Instructions for Event Ingestion Project

## Project Overview
This is a **serverless HTTP event ingestion backend** demonstrating clean architecture for receiving, validating, and storing events in AWS. The system is intentionally minimal—focus is on patterns and cost-efficiency, not completeness.

**Core Flow:** HTTP POST → API Gateway → Lambda validation → DynamoDB storage → CloudWatch logs

## Architecture & Components

### Data Flow
1. External systems POST to `/events` endpoint (API Gateway HTTP API)
2. Lambda function validates and enriches payload (adds `event_id`, `timestamp`)
3. DynamoDB stores events with hash key `event_id`
4. CloudWatch captures logs and metrics for observability

### Key Design Decisions
- **API Gateway HTTP API** (not REST): Lower cost, lower latency for ingestion-only use case
- **Lambda** for compute: No idle costs, automatic scaling
- **DynamoDB PAY_PER_REQUEST**: Optimized for bursty write traffic
- **Least-privilege IAM**: Lambda only has `dynamodb:PutItem` on events table
- **Optional TTL & PITR**: Disabled by default to minimize costs; controlled via `variables.tf`

### Out of Scope (Intentionally)
- Authentication/authorization
- Real-time analytics pipelines
- Production SLAs or compliance
- Complex validation schemas

## Terraform Structure & Conventions

**File organization follows build order:**
1. `main.tf` — DynamoDB table definition (primary resource)
2. `iam.tf` — Least-privilege roles and policies
3. `variables.tf` — Configuration inputs (environment, region, feature flags)
4. `locals.tf` — Computed values (name prefixes, tags)
5. `outputs.tf` — Exported values for downstream use
6. `providers.tf` — AWS provider config
7. `versions.tf` — Terraform version constraints

**Naming Convention:**
- Resource names: `${local.name_prefix}-{resource_type}` (e.g., `aws-event-ingestion-dev-events`)
- Always apply `local.tags` to resources for cost visibility and ownership tracking

**Key Pattern — Least-Privilege IAM:**
```hcl
# Example from iam.tf: Lambda only gets explicit PutItem action
Action = ["dynamodb:PutItem"]
Resource = aws_dynamodb_table.events.arn
```

## Lambda Handler (Python)

The Lambda function (`app/lambda_handler.py`) implements:
1. **Event validation**: Ensure required fields present
2. **Enrichment**: Add `event_id` (UUID), `timestamp`, `received_at`
3. **Error handling**: Return 400 for invalid payloads, 500 for system errors
4. **DynamoDB write**: Single `PutItem` call with enriched event

**Pattern to follow:**
- Use environment variables for table name: `os.environ['DYNAMODB_TABLE']`
- Return Lambda Proxy format: `{"statusCode": 200, "body": json.dumps({...})}`
- Include request ID in response for traceability

## Developer Workflows

### Terraform Deployment
```bash
cd infra
terraform init
terraform plan -var="env=dev" -var="aws_region=eu-north-1"
terraform apply
```

### Local Testing (Python)
- Handler accepts API Gateway Lambda Proxy event format
- Test with sample event structure: `{"body": json.dumps({...})}`

### Configuration
- **Environment-based**: Use `terraform -var="env=prod"` to switch environments
- **Feature toggles**: `enable_ttl`, `enable_pitr` control optional DynamoDB features
- **Region selection**: `aws_region` variable defaults to `eu-north-1`

## Critical Integration Points

1. **Lambda ↔ DynamoDB**: Requires `dynamodb:PutItem` permission on table ARN
2. **API Gateway ↔ Lambda**: Uses Lambda Proxy integration (event format in README architecture)
3. **Lambda ↔ CloudWatch**: Automatic via `AWSLambdaBasicExecutionRole` policy
4. **Environment variables**: Lambda receives `DYNAMODB_TABLE` and `AWS_REGION` from Terraform

## Code Conventions & Patterns

- **Terraform formatting**: Use consistent indentation, apply `terraform fmt` before committing
- **Python style**: Follow PEP 8; keep handler concise (validation + enrichment only)
- **Error handling**: Return meaningful HTTP status codes; log errors to CloudWatch
- **Testing**: Unit test validation logic separately; integration tests use Terraform-deployed stack

## Files You'll Frequently Edit

- [infra/main.tf](infra/main.tf) — DynamoDB config (table structure, TTL, encryption)
- [infra/iam.tf](infra/iam.tf) — Permissions (add actions when Lambda needs new access)
- [app/lambda_handler.py](app/lambda_handler.py) — Business logic (validation, enrichment)
- [infra/variables.tf](infra/variables.tf) — Configuration parameters

## Useful References

- [README.md](README.md) — Architecture diagram and design rationale
- `docs/architecture/` — Visual diagrams (SVG and PNG)
