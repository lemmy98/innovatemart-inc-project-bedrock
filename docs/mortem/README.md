# Mortem (problems we already solved)

This folder is a **study guide**, not a blame log.

When something failed while building this project, we wrote:

1. **What you would see** (symptom)  
2. **Why it happened** (cause)  
3. **What we changed** (fix)  
4. **What to remember** (lesson)

Read these before you fight CI for an hour. Add a new file when you hit a new issue.

## Entries

| Entry | In one sentence |
| --- | --- |
| [ci-oidc.md](ci-oidc.md) | GitHub could not assume the AWS role until bootstrap owned OIDC and trust matched new repo IDs |
| [ci-artifacts.md](ci-artifacts.md) | Apply runner was missing the Lambda zip because hidden folders are not uploaded |
| [ci-infracost.md](ci-infracost.md) | Missing Infracost key (or bad `if:` on secrets) must not block deploy |
| [ci-workflow-dispatch.md](ci-workflow-dispatch.md) | Manual destroy workflow must exist on `main` before GitHub will run it |
| [helm-provider.md](helm-provider.md) | Helm provider v3 wants `yamlencode` values, not old `set` blocks |

## How to add one

1. Create `docs/mortem/<short-name>.md`.  
2. Use the four headings above.  
3. Link it in this table.  
4. Write for a classmate: short sentences, few buzzwords, say *why* it matters.
