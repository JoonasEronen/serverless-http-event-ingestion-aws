import json
import os
import time
import uuid
import boto3

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["DYNAMODB_TABLE"]
table = dynamodb.Table(TABLE_NAME)


def lambda_handler(event, context):
    """
    Serverless HTTP event ingestion handler.
    """

    # --- Reject base64 payloads explicitly ---
    if event.get("isBase64Encoded"):
        print(json.dumps({
            "level": "WARN",
            "message": "Rejected base64 encoded payload",
            "request_id": context.aws_request_id,
        }))
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "base64 encoded payloads are not supported"}),
        }

    body_raw = event.get("body", "")

    # --- Parse JSON ---
    try:
        body = json.loads(body_raw) if body_raw else {}
    except json.JSONDecodeError:
        print(json.dumps({
            "level": "WARN",
            "message": "Invalid JSON payload",
            "request_id": context.aws_request_id,
            "body_preview": body_raw[:100],
        }))
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "invalid JSON payload"}),
        }

    # --- Validate ---
    event_type = body.get("type")
    if not event_type:
        print(json.dumps({
            "level": "WARN",
            "message": "Missing required field: type",
            "request_id": context.aws_request_id,
            "payload_keys": list(body.keys()),
        }))
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "missing required field: type"}),
        }

    # --- Enrich ---
    item = {
        "event_id": str(uuid.uuid4()),
        "type": event_type,
        "received_at": int(time.time()),
        "payload": body,
        "request_id": context.aws_request_id,
    }

    # --- Persist ---
    table.put_item(Item=item)

    # --- Success log ---
    print(json.dumps({
        "level": "INFO",
        "message": "Event ingested",
        "event_id": item["event_id"],
        "event_type": event_type,
        "request_id": context.aws_request_id,
    }))

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "event accepted",
            "event_id": item["event_id"],
            "request_id": item["request_id"],
        }),
    }
