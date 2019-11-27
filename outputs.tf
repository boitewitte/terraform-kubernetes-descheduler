output "cluster_role" {
  value = {
    name = local.cluster_role
  }
  description = "Name for the cluster role attached to the Service Account"
}

output "job" {
  value = {
    name      = kubernetes_job.descheduler.metadata[0].name
    namespace = kubernetes_job.descheduler.metadata[0].namespace
  }
  description = "Metadata for the Descheduler Job"
}

output "policy_config_map" {
  value = {
    name      = kubernetes_config_map.policy.metadata[0].name
    namespace = kubernetes_config_map.policy.metadata[0].namespace
  }

  description = "Metadata for the Policy Config Map"
}

output "service_account" {
  value = {
    name      = kubernetes_service_account.descheduler.metadata[0].name
    namespace = kubernetes_service_account.descheduler.metadata[0].namespace
  }

  description = "Metadata for the Service Account"
}

output "policy" {
  value = yamlencode(local.descheduler_policy)
}
