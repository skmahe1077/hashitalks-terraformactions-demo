import json
import os
import time

def handler(event, context):
    project = os.environ.get("PROJECT", "unknown")
    msg = {
        "project": project,
        "received_event": event,
        "note": "This log entry is created via Terraform Action for Hashitalks 2026 demo lambda Invocation",
        "ts": int(time.time())
    }
    print(json.dumps(msg))
    return {"ok": True, "logged": msg}
