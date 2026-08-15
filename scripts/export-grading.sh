#!/usr/bin/env bash
# Writes the five required non-sensitive outputs to grading.json.
# Never pipe raw `terraform output -json` to git — it can include nested sensitive values.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/terraform/envs"

terraform output -json | python3 - <<'PY' > "$ROOT/grading.json"
import json, sys
raw = json.load(sys.stdin)
allowed = ("cluster_endpoint", "cluster_name", "region", "vpc_id", "assets_bucket_name")
out = {k: raw[k] for k in allowed if k in raw}
json.dump(out, sys.stdout, indent=2)
print()
PY

echo "Wrote $ROOT/grading.json"
