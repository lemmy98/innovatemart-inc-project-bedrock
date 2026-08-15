# Bonuses 5.1–5.5

All five extras are in scope. Helm and NetworkPolicies are already in the repo. The rest wait on a live EKS cluster (and TLS waits on a real subdomain).

## 5.1 Helm

Umbrella chart: [`helm/retail-store`](../../helm/retail-store).

```bash
./scripts/helm-up.sh
# or Actions → Helm Deploy
```

YAML (`kubectl apply -k k8s/` / **K8s Deploy**) is the other path — pick **one** on EKS.

## 5.2 TLS / ACM (after the ALB exists)

FQDN: `lemikan-third-semester-exam-project.fyi` (apex). ACM cert in this account is **ISSUED**:

`arn:aws:acm:us-east-1:193854996687:certificate/1bafcd3e-d5a7-4783-af09-e5afe2180aa7`

DNS is at Cloudflare (`kyle.ns.cloudflare.com` / `gwen.ns.cloudflare.com`), not Route 53. The ALB will not show the Amazon cert to browsers while the record is **proxied** (orange cloud).

1. Confirm `kubectl -n retail-app get ingress` shows `ADDRESS` `k8s-retailap-ui-6039ab69e6-1045815775.us-east-1.elb.amazonaws.com`.
2. In Cloudflare (or the .fyi registrar if you move nameservers) create these **DNS-only (grey cloud)** records:

| Type | Name | Target |
| --- | --- | --- |
| CNAME | `@` | `k8s-retailap-ui-6039ab69e6-1045815775.us-east-1.elb.amazonaws.com` |
| CNAME | `_16e8c7cfbcc092437bab54acb1a9a870` | `_9ceb8fbfd8e4c4c6abffc3ddf6fdd8a3.jkddzztszm.acm-validations.aws.` |

Cloudflare flattens the apex CNAME. Do not orange-cloud the `@` record if graders should see the ACM issuer (`Amazon RSA 2048`).

3. Helm values / `k8s/ingress/ui.yaml` already set the hostname, `certificate-arn`, HTTPS :443, and SSL redirect.

YAML path: same annotations + `spec.rules[].host` on [`k8s/ingress/ui.yaml`](../../k8s/ingress/ui.yaml).

## 5.3–5.5 one-shot script

```bash
# Controllers + NetworkPolicies + self-heal + NP deny + IAM Deny simulate
./scripts/demo-bonuses.sh

# Also force a 3rd node for Cluster Autoscaler (costs money briefly):
RUN_CA=1 ./scripts/demo-bonuses.sh

# Or Actions → Cluster Verify (optional CA input)
```

## 5.3 Cluster Autoscaler

Node group is min 2 / desired 2 / max 3. After the shop is up:

```bash
kubectl -n kube-system get deploy cluster-autoscaler
kubectl -n retail-app scale deploy/ui --replicas=8
kubectl get nodes -w
# wait until a third node is Ready, screenshot, then:
kubectl -n retail-app scale deploy/ui --replicas=1
```

Leave the extra node until CA drains it, or it will sit on the bill.

## 5.4 NetworkPolicy

Already applied with the YAML and Helm paths. On EKS, prove:

- UI can reach catalog / carts / checkout / orders
- A probe pod in `retail-app` labelled as catalog **cannot** reach the orders Service

```bash
kubectl -n retail-app run np-deny-probe --rm -i --restart=Never \
  --labels='app.kubernetes.io/name=catalog' --image=curlimages/curl:8.5.0 --command -- \
  curl -sS -o /dev/null -w '%{http_code}' --connect-timeout 5 --max-time 10 \
  http://orders.retail-app.svc.cluster.local/actuator/health
# expect: timeout / connection failure (not HTTP 200)
```

## 5.5 Self-healing + RDS backup

RDS `backup_retention_days = 1` (must be > 0). Demo:

```bash
kubectl -n retail-app get pod -l app.kubernetes.io/name=ui
kubectl -n retail-app delete pod -l app.kubernetes.io/name=ui
kubectl -n retail-app get pod -l app.kubernetes.io/name=ui -w
```

A new UI pod should become Ready without you recreating the Deployment. In the RDS console, confirm automated backups exist for catalog and orders.

## IAM Deny delete (assets bucket)

```bash
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::ACCOUNT:user/bedrock-dev-view \
  --action-names s3:DeleteObject \
  --resource-arns arn:aws:s3:::bedrock-assets-alt-soe-tin-025-0021/x.jpg
# expect: EvalDecision = implicitDeny or explicitDeny
```
