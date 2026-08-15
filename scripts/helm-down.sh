#!/usr/bin/env bash
# Remove the Helm shop install. Does not destroy AWS / ALB controller.
set -euo pipefail
NS="${NS:-retail-app}"
RELEASE="${RELEASE:-retail-store}"
helm uninstall "$RELEASE" -n "$NS" --ignore-not-found
kubectl delete namespace "$NS" --ignore-not-found --wait=true
echo "Helm release $RELEASE and namespace $NS removed."
