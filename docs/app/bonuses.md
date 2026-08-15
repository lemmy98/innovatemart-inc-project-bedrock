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

FQDN: set `ui_hostname` in `prod.tfvars` after you have a domain + ACM cert (bonus 5.2).

1. Stage 2 until `kubectl -n retail-app get ingress` shows an `ADDRESS` (`*.elb.amazonaws.com`).
2. In Cloudflare create **two DNS-only (grey cloud)** records:

| Type | Name | Target |
| --- | --- | --- |
| CNAME | `retailstore` | ALB hostname (e.g. `k8s-retailap-ui-….elb.amazonaws.com`) |
| CNAME | `_d12425288d50d3bd6e69599c34ab3b82.retailstore` | `_f239b42418ab4ccd5084b466702ec1bd.jkddzztszm.acm-validations.aws.` |

3. Wait until ACM status is `ISSUED` for the cert in `us-east-1`.
4. Helm values / `k8s/ingress/ui.yaml` already set `ui_hostname`, `certificate-arn`, HTTPS :443, and SSL redirect — run Helm Deploy (or `./scripts/helm-up.sh`).

YAML path: same annotations + `spec.rules[].host` on [`k8s/ingress/ui.yaml`](../../k8s/ingress/ui.yaml).

## 5.3–5.5 one-shot script

```bash
# Controllers + NetworkPolicies + self-heal + NP deny + IAM Deny simulate
./scripts/demo-bonuses.sh

# Also force a 3rd node for Cluster Autoscaler (costs money briefly):
RUN_CA=1 ./scripts/demo-bonuses.sh

# Or Actions → Cluster Verify (optional CA input)
```

Operator IAM user `devlot` has an EKS Access Entry (`AmazonEKSClusterAdminPolicy`) so local `kubectl` works after Terraform apply.

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
