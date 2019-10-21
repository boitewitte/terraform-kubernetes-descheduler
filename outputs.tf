output "cluster_role_name" {
  value       = local.cluster_role
  description = "Name for the cluster role attached to the Service Account"
}

output "job" {
  value       = kubernetes_job.descheduler.metadata[0]
  description = "Metadata for the Job"
}

output "policy_config_map" {
  value       = kubernetes_config_map.policy.metadata[0]
  description = "Metadata for the Policy Config Map"
}

output "service_account" {
  value       = kubernetes_service_account.descheduler.metadata[0]
  description = "Metadata for the Service Account"
}
