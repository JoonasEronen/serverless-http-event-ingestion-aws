# Serverless HTTP Event Ingestion (AWS)

> **Project status**  
> Fully functional, deployed to AWS, and automated via CI/CD.  
> Demonstrates a production-style infrastructure workflow using Terraform and GitHub Actions.

---

## Goal

Receive → validate → enrich → store HTTP events in a cost-efficient, serverless way.

This project demonstrates a realistic cloud backend pattern commonly used for:

- Third-party webhooks
- IoT / telemetry ingestion
- Application analytics events
- Audit and logging pipelines

The focus is on **clean architecture, cost awareness, automation, and extensibility**, not on building a full product.

---

# Architecture Overview

![Architecture](docs/architecture/architecture-event-ingestion.png)

[View SVG version](docs/architecture/architecture-event-ingestion.svg)

### Flow

1. External system sends an HTTP `POST /events` request  
   *(In this project, the external webhook source is simulated using Postman.)*
2. Amazon API Gateway (HTTP API) receives the request
3. AWS Lambda:
   - validates the payload
   - enriches it with metadata (`event_id`, timestamp)
4. Amazon DynamoDB stores the raw event and metadata
5. Amazon CloudWatch collects structured logs and execution data

Later processing (analytics, replay, pipelines) is intentionally **out of scope**.

---

# Problem Statement

Build a simple, scalable backend that can receive HTTP events, perform lightweight validation, and persist them for later processing **without managing continuously running servers**.

This mirrors real-world ingestion systems where:

- Traffic is bursty
- Cost must scale with usage
- Infrastructure should stay minimal
- Observability is required for debugging

---

# First Principles Breakdown

### What is the simplest system that solves the problem?

1. **Public entry point**  
   A single HTTP endpoint external systems can call.

2. **Event-driven compute**  
   Logic that runs only when events arrive.

3. **Durable storage**  
   Events must be reliably stored for replay and later consumption.

4. **Observability**  
   Logs and traceability are required to verify correct behavior.

---

# Business Context

Many systems need a reliable way to receive events from external sources
(webhooks, devices, services) without tightly coupling those producers to internal systems.

Common challenges:

- Bursty and unpredictable traffic
- Cost inefficiency of always-on servers
- Tight coupling between producers and consumers
- Difficulty replaying or reprocessing events

This project models a minimal, decoupled ingestion layer that solves these problems
while keeping operational complexity low.

---

# Cost and Scaling Model

- No continuously running servers
- Compute billed only when events are processed
- Storage cost scales linearly with number of events
- Automatically scales with traffic

Suitable for:

- Low baseline traffic with occasional bursts
- Event-driven integrations
- Early-stage systems or internal tooling

---

# Design Decisions & Trade-offs

### API Gateway HTTP API (not REST API)
- Lower cost
- Lower latency
- Sufficient feature set for ingestion use case

### AWS Lambda
- No idle compute cost
- Automatic scaling
- Keeps API layer lightweight

### DynamoDB
- High write throughput
- No schema migrations
- Easy to extend with streams or replay patterns

---

# Infrastructure as Code

All infrastructure is defined using **Terraform**.

Provisioned resources:

- API Gateway (HTTP API)
- Lambda function and execution role
- DynamoDB table
- IAM policies and permissions
- Logging configuration

Principles:

- Reproducible deployments
- Least-privilege IAM
- Explicit tagging
- Fully automated CI/CD workflow

---

# CI/CD & Infrastructure Automation

This project is deployed using GitHub Actions with automated Terraform execution.

## Workflow Overview

### Pull Request

Opening a PR triggers:

- `terraform init`
- `terraform validate`
- `terraform plan`

Infrastructure changes are validated before merge.

![CI Pull Request](docs/architecture/ci-01-open-pull-request.png)

---

### Merge to main

Merging to `main` triggers:

- `terraform apply`
- Automatic deployment to AWS
- OIDC authentication (no static AWS keys)

![Terraform Apply Success](docs/architecture/ci-02-terraform-apply-success.png)

---

## Security Model

- No long-lived AWS credentials stored in GitHub
- GitHub → AWS authentication via OIDC
- Dedicated least-privilege IAM role for Terraform
- Fully automated and auditable infrastructure changes

This mirrors real-world infrastructure workflows where all changes are reviewed and deployed automatically.

---

# Proof of Deployment

The following screenshots demonstrate the complete end-to-end request flow.

---

## 1️⃣ HTTP Request (Simulated Webhook via Postman)

![Postman Request](docs/architecture/proof-01-postman-request.png)

- `POST /events`
- JSON payload
- 200 OK response
- Returns `event_id` and `request_id`

---

## 2️⃣ Lambda Processing (CloudWatch Logs)

![CloudWatch Log](docs/architecture/proof-02-cloudwatch-log.png)

Structured log confirms:

- Event received
- `event_id` matches API response
- `request_id` matches API response
- Successful ingestion

---

## 3️⃣ Event Persisted (DynamoDB)

![DynamoDB Item](docs/architecture/proof-03-dynamodb-item.png)

Stored item includes:

- event_id
- request_id
- payload
- received_at timestamp
- event type

This confirms full request → processing → persistence pipeline integrity.

---

# Operational Considerations

Basic operational visibility is provided via CloudWatch logs.

Traceability:

- request_id links API → Lambda → DynamoDB
- event_id uniquely identifies stored event
- Structured JSON logs for observability

In production, the system would typically add:

- Error rate alarms
- Throttling alarms
- Authentication and rate limiting
- Environment separation (dev / prod)

These are intentionally excluded to keep the system minimal and focused.

---

# Intentional Scope Limitations

Not included:

- Authentication and user management
- Frontend/UI
- Complex schema validation
- Real-time analytics pipelines
- Production SLAs and compliance hardening

This project is designed as a **foundational ingestion layer**, not a full product.

---

# Engineering Commentary

This project intentionally demonstrates:

- Infrastructure as Code using Terraform
- PR-based infrastructure validation
- Automated CI/CD deployment workflow
- Secure GitHub → AWS OIDC authentication
- Serverless cost-aware architecture
- Structured logging and traceability
- Clear trade-off decisions

While minimal in scope, the architecture models a realistic ingestion backend
that can serve as a foundation for production systems.

---

# Current State

- Fully deployed to AWS
- Public HTTP API endpoint active
- CI/CD automated via GitHub Actions
- Secure OIDC-based authentication
- End-to-end request flow verified
- All infrastructure defined as code

---

## Status

This project represents a completed baseline of a production-style,
serverless ingestion backend with automated infrastructure delivery.