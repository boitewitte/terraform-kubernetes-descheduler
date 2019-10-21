resource "kubernetes_cluster_role" "descheduler" {
  count = var.create_cluster_role ? 1 : 0

  metadata {
    name = "${var.name}-role"
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

resource "kubernetes_service_account" "descheduler" {
  metadata {
    name      = "${var.name}-sa"
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
    name = "${var.name}-role-binding"
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

locals {
  policy_volume = {
    path = "/policy-dir"
    name = "policy-volume"
    file = "policy.yaml"
  }
}

locals {
  low_node_utilization = (
    var.low_node_utilization != null
    ? {
      LowNodeUtilization = {
        enabled = true
        params = {
          nodeResourceUtilizationThresholds = var.low_node_utilization
        }
      }
    }
    : {}
  )

  remove_duplicates = (
    var.remove_duplicates != null
    ? {
      RemoveDuplicates = {
        enabled = var.remove_duplicates
      }
    }
    : {}
  )

  remove_pods_violating_inter_pod_anti_affinity = (
    var.remove_pods_violating_inter_pod_anti_affinity != null
    ? {
      RemovePodsViolatingInterPodAntiAffinity = {
        enabled = var.remove_pods_violating_inter_pod_anti_affinity
      }
    }
    : {}
  )

  remove_pods_violating_node_affinity = (
    var.remove_pods_violating_node_affinity != null
    ? {
      RemovePodsViolatingNodeAffinity = {
        enabled = true
        params = {
          nodeAffinityType = var.remove_pods_violating_node_affinity
        }
      }
    }
    : {}
  )

  strategies = merge(
    local.low_node_utilization,
    local.remove_duplicates,
    local.remove_pods_violating_inter_pod_anti_affinity,
    local.remove_pods_violating_node_affinity
  )

  descheduler_policy = {
    apiVersion = "descheduler/v1alpha1"
    kind       = "DeschedulerPolicy"
    strategies = local.strategies
  }
}

resource "kubernetes_config_map" "policy" {
  metadata {
    name = "${var.name}-config"
  }

  data = {
    "${local.policy_volume.file}" = yamlencode(local.descheduler_policy)
  }
}

resource "kubernetes_job" "descheduler" {
  metadata {
    name      = "${var.name}-job"
    namespace = var.namespace
  }

  spec {

    parallelism = 1
    completions = 1

    template {
      metadata {
        name = "${var.name}-pod"
        annotations = {
          "scheduler.alpha.kubernetes.io/critical-pod" = ""
        }
      }

      spec {
        container {
          name  = var.name
          image = var.descheduler_image

          command = [
            "/bin/descheduler",
            "--policy-config-file",
            "${local.policy_volume.path}/${local.policy_volume.file}"
          ]

          volume_mount {
            mount_path = local.policy_volume.path
            name       = local.policy_volume.name
          }
        }

        restart_policy       = "Never"
        service_account_name = kubernetes_service_account.descheduler.metadata[0].name

        volume {
          name = local.policy_volume.name

          config_map {
            name = kubernetes_config_map.policy.metadata[0].name
          }
        }
      }
    }
  }
}
