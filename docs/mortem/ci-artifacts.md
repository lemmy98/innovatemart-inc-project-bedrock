# Apply failed: Lambda zip missing on the second machine

**In plain English:** plan ran on one GitHub runner; apply ran on another and could not find the Lambda package file.

## What you would see

Plan succeeds. Apply (or destroy) dies with:

`open .../bedrock-asset-processor.zip: no such file or directory`

## Why it happened

1. We save a Terraform plan file and reuse it on apply — good for “what you approved is what you apply.”
2. Terraform also builds a zip of `lambda/` during plan.
3. That zip was under a folder named `.build/`. GitHub’s upload-artifact action **skips hidden folders** (names starting with `.`), so the zip never reached apply.
4. Even when files uploaded, download paths sometimes did not land under `terraform/envs/`.

## What we changed

- Put the zip in `terraform/modules/serverless/build/` (not hidden).
- Upload that folder with the plan artifact.
- On apply/destroy, copy `tfplan` and the zip into the expected paths; fail early if the zip is missing.
- Destroy empties the assets S3 bucket first so leftover objects do not block delete.

## Remember

A saved plan is useless if the second runner lacks files Terraform must open. Do not put CI build outputs in `.something/` folders if you upload them with the default artifact action.
