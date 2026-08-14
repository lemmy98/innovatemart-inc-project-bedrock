resource "kubernetes_namespace_v1" "app" {
  metadata {
    name = var.app_namespace
    labels = {
      "app.kubernetes.io/part-of" = "retail-store"
    }
  }
}

resource "kubernetes_secret_v1" "catalog_db" {
  metadata {
    name      = "catalog-db"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
    labels = {
      "app.kubernetes.io/managed-by" = "Helm"
    }
    annotations = {
      "meta.helm.sh/release-name"      = "catalog"
      "meta.helm.sh/release-namespace" = var.app_namespace
    }
  }

  data = {
    RETAIL_CATALOG_PERSISTENCE_USER     = var.catalog_username
    RETAIL_CATALOG_PERSISTENCE_PASSWORD = var.catalog_password
    username                            = var.catalog_username
    password                            = var.catalog_password
  }

  type = "Opaque"
}

resource "kubernetes_secret_v1" "orders_db" {
  metadata {
    name      = "orders-db"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
    labels = {
      "app.kubernetes.io/managed-by" = "Helm"
    }
    annotations = {
      "meta.helm.sh/release-name"      = "orders"
      "meta.helm.sh/release-namespace" = var.app_namespace
    }
  }

  data = {
    username = var.orders_username
    password = var.orders_password
  }

  type = "Opaque"
}

resource "helm_release" "aws_load_balancer_controller" {
  name      = "aws-load-balancer-controller"
  chart     = "${path.module}/charts/aws-load-balancer-controller-1.13.4.tgz"
  namespace = "kube-system"

  atomic          = true
  cleanup_on_fail = true
  timeout         = 300

  values = [yamlencode({
    clusterName  = var.cluster_name
    replicaCount = 1
    serviceAccount = {
      create = true
      name   = "aws-load-balancer-controller"
      annotations = {
        "eks.amazonaws.com/role-arn" = module.lb_controller_irsa.iam_role_arn
      }
    }
    resources = {
      requests = {
        cpu    = "50m"
        memory = "64Mi"
      }
    }
  })]

  depends_on = [kubernetes_namespace_v1.app]
}

resource "helm_release" "catalog" {
  name             = "catalog"
  repository       = "oci://public.ecr.aws/aws-containers"
  chart            = "retail-store-sample-catalog-chart"
  version          = var.chart_version
  namespace        = kubernetes_namespace_v1.app.metadata[0].name
  create_namespace = false
  timeout          = 300
  wait             = true

  values = [yamlencode({
    mysql = { create = false }
    resources = {
      requests = { cpu = "50m", memory = "128Mi" }
      limits   = { memory = "256Mi" }
    }
    replicaCount = 1
    app = {
      persistence = {
        provider = "mysql"
        endpoint = var.catalog_endpoint
        database = "catalog"
      }
      secret = {
        create   = false
        name     = kubernetes_secret_v1.catalog_db.metadata[0].name
        username = var.catalog_username
        password = var.catalog_password
      }
    }
  })]

  depends_on = [
    helm_release.aws_load_balancer_controller,
    kubernetes_secret_v1.catalog_db,
  ]
}

resource "helm_release" "carts" {
  name       = "carts"
  repository = "oci://public.ecr.aws/aws-containers"
  chart      = "retail-store-sample-cart-chart"
  version    = var.chart_version
  namespace  = kubernetes_namespace_v1.app.metadata[0].name
  timeout    = 300
  wait       = true

  values = [yamlencode({
    dynamodb     = { create = false }
    replicaCount = 1
    resources = {
      requests = { cpu = "50m", memory = "256Mi" }
      limits   = { memory = "384Mi" }
    }
    serviceAccount = {
      create = true
      name   = "carts"
      annotations = {
        "eks.amazonaws.com/role-arn" = module.carts_irsa.iam_role_arn
      }
    }
    app = {
      persistence = {
        provider = "dynamodb"
        dynamodb = {
          tableName   = var.dynamodb_table_name
          createTable = false
        }
      }
    }
  })]

  depends_on = [helm_release.aws_load_balancer_controller]
}

resource "helm_release" "orders" {
  name       = "orders"
  repository = "oci://public.ecr.aws/aws-containers"
  chart      = "retail-store-sample-orders-chart"
  version    = var.chart_version
  namespace  = kubernetes_namespace_v1.app.metadata[0].name
  timeout    = 360
  wait       = true

  values = [yamlencode({
    postgresql   = { create = false }
    replicaCount = 1
    resources = {
      requests = { cpu = "50m", memory = "256Mi" }
      limits   = { memory = "384Mi" }
    }
    rabbitmq = {
      create           = true
      persistentVolume = { enabled = false }
    }
    app = {
      persistence = {
        provider = "postgres"
        endpoint = var.orders_endpoint
        database = "orders"
      }
      secret = {
        create   = false
        name     = kubernetes_secret_v1.orders_db.metadata[0].name
        username = var.orders_username
        password = var.orders_password
      }
      messaging = {
        provider = "rabbitmq"
      }
    }
  })]

  depends_on = [
    helm_release.aws_load_balancer_controller,
    kubernetes_secret_v1.orders_db,
  ]
}

resource "helm_release" "checkout" {
  name       = "checkout"
  repository = "oci://public.ecr.aws/aws-containers"
  chart      = "retail-store-sample-checkout-chart"
  version    = var.chart_version
  namespace  = kubernetes_namespace_v1.app.metadata[0].name
  timeout    = 300
  wait       = true

  values = [yamlencode({
    replicaCount = 1
    resources = {
      requests = { cpu = "50m", memory = "128Mi" }
      limits   = { memory = "256Mi" }
    }
    redis = {
      create           = true
      persistentVolume = { enabled = false }
    }
    app = {
      persistence = {
        provider = "redis"
      }
      endpoints = {
        orders = "http://orders:80"
      }
    }
  })]

  depends_on = [helm_release.orders]
}

resource "helm_release" "ui" {
  name         = "ui"
  repository   = "oci://public.ecr.aws/aws-containers"
  chart        = "retail-store-sample-ui-chart"
  version      = var.chart_version
  namespace    = kubernetes_namespace_v1.app.metadata[0].name
  timeout      = 300
  wait         = true
  force_update = true

  values = [yamlencode({
    replicaCount = 1
    resources = {
      requests = { cpu = "50m", memory = "256Mi" }
      limits   = { memory = "384Mi" }
    }
    service = { type = "ClusterIP" }
    app = {
      endpoints = {
        catalog  = "http://catalog:80"
        carts    = "http://carts:80"
        orders   = "http://orders:80"
        checkout = "http://checkout:80"
      }
    }
    ingress = {
      enabled   = true
      className = "alb"
      hosts     = ["lemikan-third-semester-exam-project.fyi"]
      annotations = {
        "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
        "alb.ingress.kubernetes.io/target-type"      = "ip"
        "alb.ingress.kubernetes.io/healthcheck-path" = "/actuator/health/liveness"
        "alb.ingress.kubernetes.io/certificate-arn"  = "arn:aws:acm:us-east-1:193854996687:certificate/bafcd3e-d5a7-4783-af09-e5afe2180aa7"
        "alb.ingress.kubernetes.io/listen-ports"     = jsonencode([{ HTTP = 80 }, { HTTPS = 443 }])
        "alb.ingress.kubernetes.io/ssl-redirect"     = "443"
      }
      # Do NOT set hosts to { paths = ... }. Chart default ([]) = catch-all ALB rule.
      
    }
  })]

  depends_on = [
    helm_release.catalog,
    helm_release.carts,
    helm_release.checkout,
    helm_release.orders,
  ]
}