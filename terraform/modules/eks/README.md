# eks

Cluster, node group, access entries, control-plane logs.

The public API endpoint's allow-list is an explicit variable
(`var.public_access_cidrs`, set via `admin_access_cidrs` in `terraform/envs`)
rather than an implicit default — workstation IPv4 plus `0.0.0.0/0` for
GitHub-hosted Actions. See [docs/architecture.md](../../../docs/architecture.md).

[docs/modules/eks.md](../../../docs/modules/eks.md)
