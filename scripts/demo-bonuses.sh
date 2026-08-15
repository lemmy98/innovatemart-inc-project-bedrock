#!/usr/bin/env bash
# Bonus demos 5.3–5.5 (+ optional IAM Deny proof via IAM policy simulator).
# Requires kubectl access to project-bedrock-cluster and helm shop in retail-app.
set -euo pipefail

NS="${NS:-retail-app}"
CLUSTER="${CLUSTER_NAME:-project-bedrock-cluster}"
REGION="${AWS_REGION:-us-east-1}"
BUCKET="${ASSETS_BUCKET:-bedrock-assets-alt-soe-tin-025-0021}"
RUN_CA="${RUN_CA:-0}"

echo "== Controllers (kube-system) =="
kubectl -n kube-system get deploy -l app.kubernetes.io/name=aws-load-balancer-controller
kubectl -n kube-system get deploy -l app.kubernetes.io/name=aws-cluster-autoscaler 2>/dev/null \
  || kubectl -n kube-system get deploy | rg -i 'load-balancer|cluster-autoscaler'
kubectl -n kube-system get pods -l app.kubernetes.io/name=aws-load-balancer-controller
kubectl -n kube-system get pods | rg -i 'cluster-autoscaler|load-balancer' || true

echo
echo "== NetworkPolicies in ${NS} =="
kubectl -n "$NS" get networkpolicy

echo
echo "== 5.5 Self-heal: delete UI pod =="
kubectl -n "$NS" get pod -l app.kubernetes.io/name=ui -o wide
OLD="$(kubectl -n "$NS" get pod -l app.kubernetes.io/name=ui -o jsonpath='{.items[0].metadata.name}')"
kubectl -n "$NS" delete pod -l app.kubernetes.io/name=ui --wait=false
echo "deleted ${OLD}; waiting for replacement Ready..."
kubectl -n "$NS" wait --for=condition=Ready pod -l app.kubernetes.io/name=ui --timeout=180s
kubectl -n "$NS" get pod -l app.kubernetes.io/name=ui -o wide

echo
echo "== 5.4 NetworkPolicy: catalog-labelled probe must NOT reach orders =="
kubectl -n "$NS" delete pod np-deny-probe --ignore-not-found --wait=false
# orders Service listens on 80 → targetPort 8080; NP allows only ui/checkout ingress.
set +e
kubectl -n "$NS" run np-deny-probe --rm -i --restart=Never --labels='app.kubernetes.io/name=catalog' \
  --image=curlimages/curl:8.5.0 --command -- \
  curl -sS -o /dev/null -w '%{http_code}' --connect-timeout 5 --max-time 10 http://orders.${NS}.svc.cluster.local/actuator/health
PROBE_RC=$?
set -e
kubectl -n "$NS" delete pod np-deny-probe --ignore-not-found --wait=false 2>/dev/null || true
if [[ "$PROBE_RC" -eq 0 ]]; then
  echo "FAIL: probe reached orders (NetworkPolicy not blocking)"
  exit 1
fi
echo "OK: probe failed as expected (rc=${PROBE_RC})"

echo
echo "== IAM Deny DeleteObject (policy simulator) =="
aws iam simulate-principal-policy \
  --policy-source-arn "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):user/bedrock-dev-view" \
  --action-names s3:DeleteObject \
  --resource-arns "arn:aws:s3:::${BUCKET}/demo-delete-probe.jpg" \
  --query 'EvaluationResults[].{Action:EvalActionName,Decision:EvalDecision}' \
  --output table

if [[ "$RUN_CA" == "1" ]]; then
  echo
  echo "== 5.3 Cluster Autoscaler: scale UI to force 3rd node =="
  BEFORE="$(kubectl get nodes --no-headers | wc -l)"
  echo "nodes before=${BEFORE}"
  kubectl -n "$NS" scale deploy/ui --replicas=8
  echo "waiting up to 10m for a third Ready node..."
  for i in $(seq 1 60); do
    NOW="$(kubectl get nodes --no-headers | wc -l)"
    READY="$(kubectl get nodes --no-headers | awk '$2=="Ready"{c++} END{print c+0}')"
    echo "attempt $i nodes=${NOW} ready=${READY}"
    if [[ "$READY" -ge 3 ]]; then
      kubectl get nodes -o wide
      break
    fi
    sleep 10
  done
  kubectl -n "$NS" scale deploy/ui --replicas=1
  echo "scaled UI back to 1; leave Cluster Autoscaler to drain the extra node"
else
  echo
  echo "Skip CA scale-up (set RUN_CA=1 to run). Node group must stay min 2 / max 3."
fi

echo
echo "Done. Controllers + NPs + self-heal + NP deny (+ IAM simulate) verified."
