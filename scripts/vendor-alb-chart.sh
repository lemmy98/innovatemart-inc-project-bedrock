#!/usr/bin/env bash
# Download the AWS Load Balancer Controller Helm chart for offline/terraform apply
# when https://aws.github.io/eks-charts is unreachable (GitHub Pages blocked).
set -euo pipefail

VERSION="${1:-1.13.4}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/terraform/modules/k8s-apps/charts"
mkdir -p "$DEST"

echo "Testing https://aws.github.io/eks-charts ..."
if ! curl -fsSI --connect-timeout 10 "https://aws.github.io/eks-charts/index.yaml" >/dev/null; then
  echo "ERROR: Cannot reach aws.github.io. Use phone hotspot or fix DNS/VPN, then retry."
  exit 1
fi

helm repo add eks https://aws.github.io/eks-charts 2>/dev/null || true
helm repo update eks

helm pull eks/aws-load-balancer-controller --version "$VERSION" -d "$DEST"

echo "Saved: $DEST/aws-load-balancer-controller-${VERSION}.tgz"
echo "Commit the .tgz, then: cd terraform/envs && terraform apply -var-file=prod.tfvars"
