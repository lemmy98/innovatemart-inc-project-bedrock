resource "kubernetes_network_policy_v1" "default_deny" {
  count = var.enable_network_policies ? 1 : 0

  metadata {
    name      = "default-deny-ingress"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy_v1" "ui" {
  count = var.enable_network_policies ? 1 : 0

  metadata {
    name      = "ui"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {
        "app.kubernetes.io/name"      = "ui"
        "app.kubernetes.io/component" = "service"
      }
    }

    policy_types = ["Ingress", "Egress"]

    ingress {
      ports {
        port     = "8080"
        protocol = "TCP"
      }
    }

    egress {
      ports {
        port     = "8080"
        protocol = "TCP"
      }
      to {
        pod_selector {
          match_labels = {
            "app.kubernetes.io/name" = "catalog"
          }
        }
      }
      to {
        pod_selector {
          match_labels = {
            "app.kubernetes.io/name" = "carts"
          }
        }
      }
      to {
        pod_selector {
          match_labels = {
            "app.kubernetes.io/name" = "checkout"
          }
        }
      }
      to {
        pod_selector {
          match_labels = {
            "app.kubernetes.io/name" = "orders"
          }
        }
      }
    }

    egress {
      ports {
        port     = "53"
        protocol = "UDP"
      }
      ports {
        port     = "53"
        protocol = "TCP"
      }
    }
  }

  depends_on = [helm_release.ui]
}

resource "kubernetes_network_policy_v1" "catalog" {
  count = var.enable_network_policies ? 1 : 0

  metadata {
    name      = "catalog"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {
        "app.kubernetes.io/name" = "catalog"
      }
    }

    policy_types = ["Ingress", "Egress"]

    ingress {
      from {
        pod_selector {
          match_labels = {
            "app.kubernetes.io/name" = "ui"
          }
        }
      }
      ports {
        port     = "8080"
        protocol = "TCP"
      }
    }

    egress {
      ports {
        port     = "3306"
        protocol = "TCP"
      }
    }

    egress {
      ports {
        port     = "53"
        protocol = "UDP"
      }
      ports {
        port     = "53"
        protocol = "TCP"
      }
    }
  }

  depends_on = [helm_release.catalog]
}

resource "kubernetes_network_policy_v1" "carts" {
  count = var.enable_network_policies ? 1 : 0

  metadata {
    name      = "carts"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {
        "app.kubernetes.io/name"      = "carts"
        "app.kubernetes.io/component" = "service"
      }
    }

    policy_types = ["Ingress", "Egress"]

    ingress {
      from {
        pod_selector {
          match_labels = {
            "app.kubernetes.io/name" = "ui"
          }
        }
      }
      ports {
        port     = "8080"
        protocol = "TCP"
      }
    }

    egress {
      ports {
        port     = "443"
        protocol = "TCP"
      }
    }

    egress {
      ports {
        port     = "53"
        protocol = "UDP"
      }
      ports {
        port     = "53"
        protocol = "TCP"
      }
    }
  }

  depends_on = [helm_release.carts]
}

resource "kubernetes_network_policy_v1" "checkout" {
  count = var.enable_network_policies ? 1 : 0

  metadata {
    name      = "checkout"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {
        "app.kubernetes.io/name"      = "checkout"
        "app.kubernetes.io/component" = "service"
      }
    }

    policy_types = ["Ingress", "Egress"]

    ingress {
      from {
        pod_selector {
          match_labels = {
            "app.kubernetes.io/name" = "ui"
          }
        }
      }
      ports {
        port     = "8080"
        protocol = "TCP"
      }
    }

    egress {
      ports {
        port     = "8080"
        protocol = "TCP"
      }
      to {
        pod_selector {
          match_labels = {
            "app.kubernetes.io/name" = "orders"
          }
        }
      }
    }

    egress {
      ports {
        port     = "6379"
        protocol = "TCP"
      }
    }

    egress {
      ports {
        port     = "53"
        protocol = "UDP"
      }
      ports {
        port     = "53"
        protocol = "TCP"
      }
    }
  }

  depends_on = [helm_release.checkout]
}

resource "kubernetes_network_policy_v1" "orders" {
  count = var.enable_network_policies ? 1 : 0

  metadata {
    name      = "orders"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {
        "app.kubernetes.io/name"      = "orders"
        "app.kubernetes.io/component" = "service"
      }
    }

    policy_types = ["Ingress", "Egress"]

    ingress {
      from {
        pod_selector {
          match_labels = {
            "app.kubernetes.io/name" = "ui"
          }
        }
      }
      from {
        pod_selector {
          match_labels = {
            "app.kubernetes.io/name" = "checkout"
          }
        }
      }
      ports {
        port     = "8080"
        protocol = "TCP"
      }
    }

    egress {
      ports {
        port     = "5432"
        protocol = "TCP"
      }
      ports {
        port     = "5672"
        protocol = "TCP"
      }
      ports {
        port     = "53"
        protocol = "UDP"
      }
      ports {
        port     = "53"
        protocol = "TCP"
      }
    }
  }

  depends_on = [helm_release.orders]
}
