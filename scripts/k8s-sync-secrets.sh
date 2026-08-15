#!/usr/bin/env bash
# Create Kubernetes Secrets in retail-app from AWS Secrets Manager.
# Never writes passwords to the working tree.
set -euo pipefail

NS="${NS:-retail-app}"
REGION="${AWS_REGION:-us-east-1}"
NAME_PREFIX="${NAME_PREFIX:-bedrock}"
CLUSTER_NAME="${CLUSTER_NAME:-project-bedrock-cluster}"

need() { command -v "$1" >/dev/null 2>&1 || { echo "missing $1"; exit 1; }; }
need aws
need kubectl
need python3

kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

sm_get() {
  aws secretsmanager get-secret-value \
    --region "$REGION" \
    --secret-id "$1" \
    --query SecretString \
    --output text
}

json_get() {
  python3 -c 'import json,sys; print(json.load(sys.stdin)[sys.argv[1]])' "$1"
}

echo "Reading ${NAME_PREFIX}/catalog-db from Secrets Manager…"
catalog_json="$(sm_get "${NAME_PREFIX}/catalog-db")"
catalog_user="$(printf '%s' "$catalog_json" | json_get username)"
catalog_pass="$(printf '%s' "$catalog_json" | json_get password)"
catalog_host="$(printf '%s' "$catalog_json" | json_get host)"
catalog_port="$(printf '%s' "$catalog_json" | json_get port)"

echo "Reading ${NAME_PREFIX}/orders-db from Secrets Manager…"
orders_json="$(sm_get "${NAME_PREFIX}/orders-db")"
orders_user="$(printf '%s' "$orders_json" | json_get username)"
orders_pass="$(printf '%s' "$orders_json" | json_get password)"
orders_host="$(printf '%s' "$orders_json" | json_get host)"
orders_port="$(printf '%s' "$orders_json" | json_get port)"

kubectl -n "$NS" create secret generic catalog-db \
  --from-literal=RETAIL_CATALOG_PERSISTENCE_USER="$catalog_user" \
  --from-literal=RETAIL_CATALOG_PERSISTENCE_PASSWORD="$catalog_pass" \
  --from-literal=RETAIL_CATALOG_PERSISTENCE_ENDPOINT="${catalog_host}:${catalog_port}" \
  --from-literal=username="$catalog_user" \
  --from-literal=password="$catalog_pass" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "$NS" create secret generic orders-db \
  --from-literal=RETAIL_ORDERS_PERSISTENCE_USERNAME="$orders_user" \
  --from-literal=RETAIL_ORDERS_PERSISTENCE_PASSWORD="$orders_pass" \
  --from-literal=RETAIL_ORDERS_PERSISTENCE_ENDPOINT="${orders_host}:${orders_port}" \
  --from-literal=username="$orders_user" \
  --from-literal=password="$orders_pass" \
  --dry-run=client -o yaml | kubectl apply -f -

role_arn="${CARTS_IRSA_ROLE_ARN:-}"
if [[ -z "$role_arn" ]]; then
  role_arn="$(aws iam get-role --role-name "${CLUSTER_NAME}-carts" --query 'Role.Arn' --output text 2>/dev/null || true)"
fi
if [[ -n "$role_arn" && "$role_arn" != "None" ]]; then
  if kubectl -n "$NS" get serviceaccount carts >/dev/null 2>&1; then
    kubectl -n "$NS" annotate serviceaccount carts \
      "eks.amazonaws.com/role-arn=${role_arn}" --overwrite
    echo "Annotated serviceaccount/carts with IRSA ${role_arn}"
  else
    echo "Note: serviceaccount/carts not applied yet. Re-run after kubectl apply -k k8s/ to attach IRSA ${role_arn}"
  fi
else
  echo "Note: IAM role ${CLUSTER_NAME}-carts not found. Enable Terraform enable_app_deploy for carts IRSA."
  echo "      Or pass CARTS_IRSA_ROLE_ARN."
fi

if kubectl -n "$NS" get secret orders-rabbitmq >/dev/null 2>&1; then
  echo "Secret orders-rabbitmq already exists (not rotated)."
else
  rabbit_pass="$(openssl rand -base64 18 | tr -d '/+=' | cut -c1-20)"
  kubectl -n "$NS" create secret generic orders-rabbitmq \
    --from-literal=RETAIL_ORDERS_MESSAGING_RABBITMQ_USERNAME=orders \
    --from-literal=RETAIL_ORDERS_MESSAGING_RABBITMQ_PASSWORD="$rabbit_pass"
  echo "Created in-cluster secret orders-rabbitmq (not stored in git or Secrets Manager)."
fi

echo "Kubernetes secrets catalog-db, orders-db, and orders-rabbitmq are in place in $NS."
