#!/usr/bin/env bash
# Apply k8s/ (Kustomize) into namespace retail-app on the current kube context.
# Pulls DB credentials from AWS Secrets Manager first. Does not use Helm.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NS="${NS:-retail-app}"

if [[ "${SKIP_SECRET_SYNC:-}" != "1" ]]; then
  "$ROOT/scripts/k8s-sync-secrets.sh"
fi

kubectl apply -k "$ROOT/k8s"
echo "Waiting for pods in $NS…"
kubectl wait --for=condition=Ready pods --all -n "$NS" --timeout=180s
kubectl get pods,svc,ingress -n "$NS"
echo
echo "UI: kubectl -n $NS get ingress"
echo "Down: $ROOT/scripts/k8s-down.sh"
echo "Do not also run Terraform Helm shop charts on the same cluster (this repo applies the shop only via k8s/).
Terraform `enable_app_deploy` still installs the ALB controller + Cluster Autoscaler."
