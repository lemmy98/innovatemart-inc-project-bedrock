# Helm provider v3 vs red squiggles in the editor

**In plain English:** the editor complained about Helm Terraform code even when `terraform validate` was fine — the provider API had changed.

## What you would see

Terraform language server / IDE marks `helm_release` as wrong (`set` blocks, unexpected schema). Validate may still pass after pinning, until the code matches Helm provider **v3**.

## Why it happened

Helm provider v3 changed how you pass values and how it talks to Kubernetes. Old `set { }` blocks and nested `kubernetes { }` blocks no longer match. Sometimes the editor also caches an old schema and keeps showing red after you fix the file.

## What we changed

- Pass values with `values = [yamlencode(...)]`.
- Connect Helm to the cluster the v3 way.
- In CI, `terraform_wrapper: false` so plan files stay valid between jobs.
- Reload the editor tab if a fixed file still looks broken.

## Remember

Provider major upgrades break old syntax. Prefer one `yamlencode` blob for Helm values. If validate is green and the editor is red, reload before rewriting everything.
