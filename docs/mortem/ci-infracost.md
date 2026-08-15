# Infracost must not block the whole deploy

**In plain English:** cost estimate is nice-to-have; missing the API key almost stopped the real Terraform plan from being used.

## What you would see

Terraform plan works, then the job fails on **Infracost**. The plan artifact never uploads, so approval/apply never start.

Or the workflow dies in **0 seconds** with a “workflow file issue” after editing an `if:` that mentioned `secrets.*`.

## Why it happened

1. Infracost needs `INFRACOST_API_KEY`. We had not set it (optional — not an exam requirement).
2. GitHub **forbids** using `secrets` inside step `if:` conditions. The YAML is rejected before any job runs.

## What we changed

- Copy the secret into `env.INFRACOST_API_KEY`, then check `env.INFRACOST_API_KEY != ''`.
- Skip cost steps when the key is empty; still upload the Terraform plan.
- Soft-fail cost steps so a bad key cannot sink deploy.

## Remember

Infracost is a report, not a gate. Never write `if: secrets.SOMETHING` — use an env var instead.
