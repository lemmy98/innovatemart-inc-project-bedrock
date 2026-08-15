# Mortem

Study notes from failures I already hit. I read these before I fight CI for an hour.

Each entry: **what I see** → **why** → **what I changed** → **what I must remember**.

| Entry | In one sentence |
| --- | --- |
| [ci-oidc.md](ci-oidc.md) | GitHub could not assume the AWS role until bootstrap owned OIDC and trust matched the repo |
| [ci-artifacts.md](ci-artifacts.md) | Apply runner was missing the Lambda zip because hidden folders are not uploaded |
| [ci-infracost.md](ci-infracost.md) | A missing Infracost key must not block deploy |
| [ci-workflow-dispatch.md](ci-workflow-dispatch.md) | Manual destroy must exist on `main` before GitHub will run it |
| [helm-provider.md](helm-provider.md) | Helm provider v3 wants `yamlencode` values, not old `set` blocks |

To add one: I create `docs/mortem/<short-name>.md` with those four headings, then link it here.
