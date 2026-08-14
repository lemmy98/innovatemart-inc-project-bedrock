"""S3 object-created handler — exam requires log line: Image received: <filename>"""


import json
import logging
import urllib.parse

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    records = event.get("Records", [])
    processed = []

    for record in records:
        bucket = record["s3"]["bucket"]["name"]
        key = urllib.parse.unquote_plus(record["s3"]["object"]["key"])
        logger.info("Image received: %s", key)
        processed.append({"bucket": bucket, "key": key})

    return {
        "statusCode": 200,
        "body": json.dumps({"processed": processed}),
    }
