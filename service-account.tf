resource "kubernetes_service_account" "descheduler" {
  metadata {
    name      = format("%s-%s", var.name, "sa")
    namespace = var.namespace
  }
}

locals {
  cluster_role = (
    var.create_cluster_role
    ? kubernetes_cluster_role.descheduler[0].metadata[0].name
    : var.cluster_role
  )
}

resource "kubernetes_cluster_role_binding" "descheduler" {
  metadata {
    name = format("%s-%s", var.name, "role-binding")
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = local.cluster_role
  }

  subject {
    kind      = "Service Account"
    name      = kubernetes_service_account.descheduler.metadata[0].name
    namespace = kubernetes_service_account.descheduler.metadata[0].namespace
  }
}
