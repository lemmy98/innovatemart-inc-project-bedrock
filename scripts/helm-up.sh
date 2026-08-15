#!/usr/bin/env bash
# Install the retail-store Helm umbrella onto EKS (bonus 5.1).
# Uses RDS/DynamoDB from Terraform + Secrets Manager. Do not run while k8s/ YAML is live
# unless REPLACE_EXISTING=1 (default in CI).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHART="$ROOT/helm/retail-store"
NS="${NS:-retail-app}"
RELEASE="${RELEASE:-retail-store}"
REGION="${AWS_REGION:-us-east-1}"
CLUSTER_NAME="${CLUSTER_NAME:-project-bedrock-cluster}"
NAME_PREFIX="${NAME_PREFIX:-bedrock}"
REPLACE_EXISTING="${REPLACE_EXISTING:-0}"

need() { command -v "$1" >/dev/null 2>&1 || { echo "missing $1"; exit 1; }; }
need aws
need kubectl
need helm
need python3
need openssl

json_get() {
  python3 -c 'import json,sys; print(json.load(sys.stdin)[sys.argv[1]])' "$1"
}

sm_get() {
  aws secretsmanager get-secret-value \
    --region "$REGION" \
    --secret-id "$1" \
    --query SecretString \
    --output text
}

if [[ "$REPLACE_EXISTING" == "1" ]]; then
  echo "Removing previous shop install in $NS (YAML or Helm)…"
  helm uninstall "$RELEASE" -n "$NS" --ignore-not-found 2>/dev/null || true
  kubectl delete namespace "$NS" --ignore-not-found --wait=true
fi

kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

echo "Reading DB secrets from Secrets Manager…"
catalog_json="$(sm_get "${NAME_PREFIX}/catalog-db")"
orders_json="$(sm_get "${NAME_PREFIX}/orders-db")"
catalog_user="$(printf '%s' "$catalog_json" | json_get username)"
catalog_pass="$(printf '%s' "$catalog_json" | json_get password)"
catalog_host="$(printf '%s' "$catalog_json" | json_get host)"
catalog_port="$(printf '%s' "$catalog_json" | json_get port)"
orders_user="$(printf '%s' "$orders_json" | json_get username)"
orders_pass="$(printf '%s' "$orders_json" | json_get password)"
orders_host="$(printf '%s' "$orders_json" | json_get host)"
orders_port="$(printf '%s' "$orders_json" | json_get port)"
catalog_endpoint="${catalog_host}:${catalog_port}"
orders_endpoint="${orders_host}:${orders_port}"

kubectl -n "$NS" create secret generic catalog-db \
  --from-literal=RETAIL_CATALOG_PERSISTENCE_USER="$catalog_user" \
  --from-literal=RETAIL_CATALOG_PERSISTENCE_PASSWORD="$catalog_pass" \
  --from-literal=RETAIL_CATALOG_PERSISTENCE_ENDPOINT="$catalog_endpoint" \
  --from-literal=username="$catalog_user" \
  --from-literal=password="$catalog_pass" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "$NS" create secret generic orders-db \
  --from-literal=RETAIL_ORDERS_PERSISTENCE_USERNAME="$orders_user" \
  --from-literal=RETAIL_ORDERS_PERSISTENCE_PASSWORD="$orders_pass" \
  --from-literal=RETAIL_ORDERS_PERSISTENCE_ENDPOINT="$orders_endpoint" \
  --from-literal=username="$orders_user" \
  --from-literal=password="$orders_pass" \
  --dry-run=client -o yaml | kubectl apply -f -

rabbit_pass="$(openssl rand -base64 18 | tr -d '/+=' | cut -c1-20)"
role_arn="${CARTS_IRSA_ROLE_ARN:-}"
if [[ -z "$role_arn" ]]; then
  role_arn="$(aws iam get-role --role-name "${CLUSTER_NAME}-carts" --query 'Role.Arn' --output text 2>/dev/null || true)"
fi
[[ -n "$role_arn" && "$role_arn" != "None" ]] || {
  echo "missing carts IRSA role ${CLUSTER_NAME}-carts (enable_app_deploy in Terraform)"
  exit 1
}

echo "Resolving chart dependencies…"
if [[ "$(find "$CHART/charts" -name '*.tgz' 2>/dev/null | wc -l)" -ge 5 ]]; then
  echo "Using vendored charts in $CHART/charts (skip ECR Public pull)"
else
  for attempt in 1 2 3 4 5 6; do
    if helm dependency update "$CHART"; then
      break
    fi
    echo "helm dependency update failed (attempt $attempt); waiting for ECR Public…"
    sleep $((attempt * 20))
    if [[ "$attempt" -eq 6 ]]; then
      echo "Could not pull chart dependencies from public.ecr.aws"
      exit 1
    fi
  done
fi

echo "helm upgrade --install $RELEASE …"
helm upgrade --install "$RELEASE" "$CHART" \
  --namespace "$NS" \
  --create-namespace \
  -f "$CHART/values.yaml" \
  --set catalog.app.persistence.endpoint="$catalog_endpoint" \
  --set orders.app.persistence.endpoint="$orders_endpoint" \
  --set orders.app.messaging.rabbitmq.secret.username=orders \
  --set orders.app.messaging.rabbitmq.secret.password="$rabbit_pass" \
  --set-string "carts.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn=$role_arn" \
  --wait --timeout 12m

# Upstream RabbitMQ STS has no RABBITMQ_DEFAULT_* — patch to match the messaging secret.
kubectl -n "$NS" set env statefulset/orders-rabbitmq \
  RABBITMQ_DEFAULT_USER=orders \
  RABBITMQ_DEFAULT_PASS="$rabbit_pass" \
  --overwrite
kubectl -n "$NS" rollout status statefulset/orders-rabbitmq --timeout=180s
kubectl -n "$NS" rollout restart deployment/orders
kubectl -n "$NS" set env deployment/carts AWS_REGION="$REGION" AWS_DEFAULT_REGION="$REGION" --overwrite
kubectl -n "$NS" rollout status deployment/orders --timeout=300s
kubectl -n "$NS" rollout status deployment/carts --timeout=300s
kubectl -n "$NS" rollout status deployment/catalog --timeout=300s
kubectl -n "$NS" rollout status deployment/checkout --timeout=300s
kubectl -n "$NS" rollout status deployment/ui --timeout=300s

# Bonus NetworkPolicies (same as YAML path) — must target the app namespace
kubectl apply -n "$NS" -f "$ROOT/k8s/networkpolicies/"

echo
kubectl -n "$NS" get pods,svc,ingress
echo
echo "UI Ingress:"
kubectl -n "$NS" get ingress -o wide
echo
echo "Down: helm uninstall $RELEASE -n $NS && kubectl delete ns $NS"
echo "YAML path: do not kubectl apply -k k8s/ while this Helm release is live."
