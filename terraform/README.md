# terraform/

`bootstrap/` — S3 state bucket + GitHub OIDC role. I apply this first.  
`envs/` — root module; calls `modules/`.  
`modules/` — one folder per concern.

Write-up: [docs/terraform](../docs/terraform/README.md). I start at [stages](../docs/terraform/stages.md).
