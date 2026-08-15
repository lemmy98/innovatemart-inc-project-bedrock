# Destroy button missing until the file is on main

**In plain English:** you cannot manually start a workflow that only exists on `dev`. GitHub only “registers” manual workflows from the default branch.

## What you would see

```text
HTTP 404: workflow terraform-destroy.yml not found on the default branch
```

even though the file is on `dev`.

## Why it happened

For `workflow_dispatch` (Actions → Run workflow / `gh workflow run`), the workflow file must exist on **`main`**. You can still *run* it against `dev`, but `main` must know the workflow exists.

## What we changed

- Put `terraform-destroy.yml` on `main` and keep the same file on `dev`.
- While testing, run with `--ref dev`; the workflow still checks you typed `destroy` and that the ref is `dev`.
- Merged so both branches stay aligned.

## Remember

Any “click to run” workflow needs to live on the default branch first. Feature-branch-only dispatch files stay invisible.
