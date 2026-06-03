import json
import os
import uuid
from datetime import datetime

def lambda_handler(event, context):
    incident_id = str(uuid.uuid4())

    incident_record = {
        "incident_id": incident_id,
        "timestamp": datetime.utcnow().isoformat(),
        "source": "cloudwatch",
        "status": "NEW",
        "message": "Incident triage Lambda triggered successfully",
        "event": event
    }

    print("AI CloudOps Incident Triage Event:")
    print(json.dumps(incident_record, indent=2))

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Incident processed successfully",
            "incident_id": incident_id
        })
    }
