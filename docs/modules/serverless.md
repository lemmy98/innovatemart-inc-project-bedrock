# serverless

## What it is

- Private S3 bucket `bedrock-assets-<student-slug>`
- Lambda `bedrock-asset-processor` (Python 3.12, 128 MB) on `s3:ObjectCreated:*`
- Log line: `Image received: <filename>`

## Why

| Decision | Thought process | Advantage |
| --- | --- | --- |
| Block Public Access + SSE-S3 | Assets are not a public website | Default secure bucket |
| Tiny Lambda | Exam only checks the log format | Cheap and simple |
| Least-privilege role | Only `s3:GetObject` on the bucket + log writes | No broad `*` policies |

## Quick test (after apply)

```bash
echo test > /tmp/demo.jpg
aws s3 cp /tmp/demo.jpg s3://bedrock-assets-alt-soe-tin-025-0021/demo.jpg
aws logs tail /aws/lambda/bedrock-asset-processor --since 5m
# expect: Image received: demo.jpg
```
