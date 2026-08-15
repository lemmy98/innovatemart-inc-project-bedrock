#!/usr/bin/env bash
# Remove the YAML install (namespace retail-app). Does not destroy AWS.
set -euo pipefail
NS="${NS:-retail-app}"
kubectl delete namespace "$NS" --ignore-not-found --wait=true
echo "Namespace $NS removed from the current kube context."
