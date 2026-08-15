# eks

Cluster, node group, access entries, control-plane logs.

The public API endpoint's allow-list is an explicit variable
(`var.public_access_cidrs`, set via `admin_access_cidrs` in `terraform/envs`)
rather than an implicit default — currently `["0.0.0.0/0"]` because every CI
job that talks to the cluster runs on a GitHub-hosted runner with dynamic
IPs. See the variable description and
[docs/architecture.md](../../../docs/architecture.md) for how to tighten this
once a self-hosted runner exists.

[docs/modules/eks.md](../../../docs/modules/eks.md)
