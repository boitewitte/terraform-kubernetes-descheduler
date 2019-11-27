locals {
  policy_volume = {
    path = lookup(var.policy_cm_volume, "path", "/policy-dir"),
    name = lookup(var.policy_cm_volume, "name", "policy-volume"),
    file = lookup(var.policy_cm_volume, "file", "policy.yaml")
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
    name = format("%s-%s", var.name, "policy")
  }

  data = {
    "${local.policy_volume.file}" = yamlencode(local.descheduler_policy)
  }
}
