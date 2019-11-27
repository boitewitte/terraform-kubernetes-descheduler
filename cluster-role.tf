resource "kubernetes_cluster_role" "descheduler" {
  count = var.create_cluster_role ? 1 : 0

  metadata {
    name = format("%s-%s", var.name, "role")
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "watch", "list"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "watch", "list", "delete"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/eviction"]
    verbs      = ["create"]
  }
}
