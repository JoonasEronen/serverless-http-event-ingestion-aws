# Serverless HTTP Event Ingestion (AWS)

> **Project status**  
> This project is fully functional and deployed to AWS.
> It represents a realistic, working serverless ingestion backend.
>
> Documentation reflects a realistic cloud engineering workflow and
> explicitly highlights production-level considerations that are
> intentionally out of scope for this version.

## Goal
Receive → validate → enrich → store HTTP events in a cost-efficient, serverless way.

This project demonstrates a realistic cloud backend pattern commonly used for:
- Third-party webhooks
- IoT / telemetry ingestion
- Application analytics events
- Audit and logging pipelines

The focus is on **clean architecture, cost awareness, and extensibility**, not on building a full product.

---

## Architecture Overview

![Architecture](docs/architecture/architecture-event-ingestion.png)

[View SVG version](docs/architecture/architecture-event-ingestion.svg)


### Flow
1. External system sends an HTTP `POST /events` request
   *(In this project, the external webhook source is simulated using Postman for testing purposes.)*
2. Amazon API Gateway (HTTP API) receives the request
3. AWS Lambda:
   - validates the payload
   - enriches it with metadata (timestamp, event_id)
4. Amazon DynamoDB stores the raw event and metadata
5. Amazon CloudWatch collects logs, metrics, and errors

Later processing (analytics, replay, pipelines) is intentionally **out of scope** for this project.

---

## Problem Statement
Build a simple, scalable backend that can receive HTTP events, perform lightweight validation, and persist them for later processing **without managing any continuously active servers**.

This mirrors real-world ingestion systems where:
- traffic is bursty
- cost must scale with usage
- infrastructure should stay minimal

---

## First Principles Breakdown

### What is the simplest system that solves the problem?

1. **Public entry point**  
   A single HTTP endpoint that external systems can call.

2. **Event-driven compute**  
   Logic that runs only when an event arrives.

3. **Durable storage**  
   Events must be stored reliably for later consumption.

4. **Observability**  
   Logs and metrics are required to verify correct behavior and debug issues.

---

## Business Context

Many systems need a reliable way to receive events from external sources
(webhooks, devices, services) without tightly coupling those sources to internal systems.

Common challenges include:
- Bursty and unpredictable traffic
- Cost inefficiency of always-on servers
- Tight coupling between producers and consumers
- Difficulty replaying or reprocessing events

This project models a simple, decoupled ingestion layer that solves these problems
while keeping operational and cost complexity low.

---

## Cost and Scaling Model

This system is designed to scale with usage and remain inexpensive at low traffic volumes.

- No continuously running servers
- Compute is billed only when events are processed
- Storage cost scales linearly with the number of events

Typical usage scenarios:
- Low baseline traffic with occasional bursts
- Event-driven integrations rather than constant polling

This makes the solution suitable for early-stage systems,
internal tooling, and ingestion pipelines where cost predictability matters.

---

## Design Decisions & Trade-offs

### API Gateway HTTP API (not REST API)
- Lower cost
- Lower latency
- Sufficient feature set for ingestion-only use case

### AWS Lambda for validation
- No idle compute cost
- Scales automatically with traffic
- Keeps API Gateway configuration simple

### DynamoDB for event storage
- Optimized for high write throughput
- No schema migrations
- Easy to attach future consumers (streams, analytics, replay)

## Intentional Scope Limitations
The following features are intentionally excluded to keep the system focused
on ingestion reliability and cost-efficiency rather than full product concerns:

- Authentication and user management
- Frontend/UI
- Complex schemas and validation rules
- Real-time processing pipelines
- Analytics dashboards
- Production SLAs and compliance requirements

This project is designed as a **foundation**, not a finished product.

---

## Infrastructure as Code

All infrastructure for this project is defined and deployed using **Terraform**.

Key principles:
- Reproducible deployments
- Clear separation of concerns
- Least-privilege IAM permissions
- Explicit tagging for cost visibility

The current Terraform configuration provisions the full system:
- API Gateway (HTTP API)
- Lambda function and execution role
- DynamoDB table
- Required IAM policies and permissions

The infrastructure reflects a completed, working baseline that can be
extended further as requirements evolve.

All resources are deployed to an AWS account using `terraform apply`,
and the system is actively handling test traffic via the public HTTP endpoint.

---

## Current State

- Fully deployed to AWS using Terraform
- Public HTTP API receiving events
- Lambda-based validation and enrichment
- Events persisted in DynamoDB
- Logs and metrics available in CloudWatch

The system is intentionally minimal to emphasize correctness,
cost-awareness, and clear service boundaries.

---

## Operational Considerations

Basic operational visibility is provided via CloudWatch logs and metrics.

- Request flow can be traced using request_id and event_id
- Lambda logs provide validation and processing visibility
- DynamoDB acts as a durable source of truth for received events

In a production environment, this system would typically be extended with:
- Alarms for error rates and throttling
- Access controls and rate limiting
- Structured error classification

These are intentionally excluded from the current version to keep the system minimal.

---

## Next Iteration (Production Considerations)

The following items are intentionally excluded from the current version,
but represent typical production concerns for an ingestion system:

- Authentication and authorization
- Request rate limiting and abuse protection
- Enhanced schema validation and error classification
- Alerting for error rates and throttling
- Environment separation (dev / prod)

They are omitted here to keep the project focused on ingestion reliability,
cost efficiency, and architectural clarity rather than full product hardening.

---

## CI/CD and Infrastructure Maturity (Planned)

The current version of this project is deployed using Terraform from a local environment.
CI/CD is not yet implemented in this version.

The next iteration will introduce a fully automated CI/CD workflow with:
- GitHub Actions for automated validation and deployment
- Terraform remote state (S3 backend)
- State locking (DynamoDB)
- GitHub → AWS authentication using OIDC (no long-lived credentials)
- Branch protection and PR-based infrastructure validation

The goal of this iteration is to evolve the project from a manually deployed MVP
into a production-style, automation-driven infrastructure workflow.

This reflects real-world engineering practices where infrastructure changes
are validated, reviewed, and deployed automatically.