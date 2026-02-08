# Project 1 – Serverless HTTP Event Ingestion (AWS)

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

### What is intentionally excluded
- Authentication and user management
- Frontend/UI
- Complex schemas and validation rules
- Real-time processing pipelines
- Analytics dashboards
- Production SLAs and compliance requirements

This project is designed as a **foundation**, not a finished product.

---

## Infrastructure as Code
All infrastructure is defined using **Terraform**.

Key principles:
- Reproducible deployments
- Clear separation of concerns
- Least-privilege IAM permissions
- Explicit tagging for cost visibility

Terraform implementation is added incrementally as the infrastructure is built.