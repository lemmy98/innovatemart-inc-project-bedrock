# Cluster Autoscaler discovers managed node groups via ASG tags.
# EKS does not copy node-group tags onto the ASG, so we tag the ASG after it exists.
# for_each keys must be static — ASG names are only known after the node group applies.

locals {
  # Must match keys in eks_managed_node_groups in main.tf
  managed_node_group_keys = toset(["retail"])
}

resource "aws_autoscaling_group_tag" "cluster_autoscaler_enabled" {
  for_each = local.managed_node_group_keys

  autoscaling_group_name = module.eks.eks_managed_node_groups[each.key].node_group_autoscaling_group_names[0]

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = false
  }
}

resource "aws_autoscaling_group_tag" "cluster_autoscaler_owned" {
  for_each = local.managed_node_group_keys

  autoscaling_group_name = module.eks.eks_managed_node_groups[each.key].node_group_autoscaling_group_names[0]

  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = false
  }
}
