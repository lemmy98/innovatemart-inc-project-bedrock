#!/usr/bin/env bash
# Writes the five required non-sensitive outputs to grading.json.
# Never pipe raw `terraform output -json` to git — it can include nested sensitive values.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/terraform/envs"

# Piping into `python3 - <<'PY'` doesn't work: the heredoc redirection wins
# over the pipe for python3's stdin, so the script consumes itself as input
# and `terraform output -json` is silently discarded. Feed the script via
# process substitution instead, leaving stdin free for the piped output.
terraform output -json | python3 <(cat <<'PY'
import json, sys
raw = json.load(sys.stdin)
allowed = ("cluster_endpoint", "cluster_name", "region", "vpc_id", "assets_bucket_name")
out = {k: raw[k] for k in allowed if k in raw}
json.dump(out, sys.stdout, indent=2)
print()
PY
) > "$ROOT/grading.json"

echo "Wrote $ROOT/grading.json"
