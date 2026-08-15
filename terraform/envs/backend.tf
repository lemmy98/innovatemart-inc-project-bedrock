terraform {
  backend "s3" {
    # Bucket and key come from backend.hcl (gitignored, account-specific).
    # Native S3 lock file — Terraform 1.11+; no DynamoDB table required.
    encrypt      = true
    use_lockfile = true
  }
}
