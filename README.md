# Project 1 – Serverless Event Ingestion Backend

## Problem Statement
Build a simple, cost-efficient, and scalable backend that receives HTTP events, performs basic validation, and stores them for later processing, without running a continuously active server.

This represents common real-world needs such as webhooks, IoT event ingestion, application analytics events, and audit/telemetry logging.

## First Principles Breakdown

### What is the simplest thing that must exist?
At the most basic level, we need:

1. **An entry point (endpoint)**  
   A public HTTP endpoint that external systems can send events to.

2. **A compute step to handle the event**  
   Something that runs only when an event arrives, validates the payload, and prepares it for storage.

3. **A durable place to store the event**  
   The event must be saved reliably so it can be processed later.

4. **Observability**  
   Logs are required to verify requests, debug failures, and prove that the system works.

### What is intentionally excluded (for this project)?
To keep the scope focused and realistic for a first portfolio project, we intentionally exclude:

- User accounts and authentication
- Frontend/UI
- Complex validation rules and schemas
- Real-time processing pipelines
- Data analytics dashboards
- Production-grade SLAs and compliance
- Always-on public demo endpoints

The goal is to demonstrate a clean foundation that can be extended in later projects.
