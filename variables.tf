variable "cluster_role" {
  type        = string
  description = "The cluster role to attach to the Descheduler Service Account, only used when a create_cluster_role = false"
  default     = null
}

variable "create_cluster_role" {
  type        = bool
  description = "Create Cluster Role needed for Descheduler"
  default     = true
}

variable "image" {
  type = object({
    name = string
    tag  = string
  })
  description = "The Image for the Descheduler"
}

variable "image_pull_secret" {
  type        = string
  description = "Secret containing the .dockerconfig file for getting the Pull Secret"
  default     = null
}

# variable "descheduler_image" {
#   type        = string
#   description = "The Image for the Descheduler"
# }

variable "name" {
  type        = string
  description = "Name for the Descheduler"
  default     = "descheduler"
}

variable "namespace" {
  type        = string
  description = "The namespace to which the Descheduler is deployed"
  default     = "kube-system"
}


# ############################ #
# Descheduler Policy ConfigMap #
# ############################ #

variable "policy_cm_volume" {
  type        = map(string)
  description = "Configuration for the Volume of the ConfigMap containing the Descheduler Policy"
  default = {
    path = "/policy-dir"
    name = "policy-volume"
    file = "policy.yaml"
  }
}

# ############################# #
# Descheduler Policy Strategies #
# ############################# #

variable "low_node_utilization" {
  type = object({
    tresholds = object({
      cpu    = number,
      memory = number,
      pods   = number,
    }),
    targetThresholds = object({
      cpu    = number,
      memory = number,
      pods   = number
    })
  })
  description = "This strategy finds nodes that are under utilized and evicts pods, if possible, from other nodes in the hope that recreation of evicted pods will be scheduled on these underutilized nodes."
  default     = null
}

variable "remove_duplicates" {
  type        = bool
  description = "This strategy makes sure that there is only one pod associated with a Replica Set (RS), Replication Controller (RC), Deployment, or Job running on same node."
  default     = null
}

variable "remove_pods_violating_inter_pod_anti_affinity" {
  type        = bool
  description = "This strategy makes sure that pods violating interpod anti-affinity are removed from nodes."
  default     = null
}

variable "remove_pods_violating_node_affinity" {
  type        = list(string)
  description = "This strategy makes sure that pods violating node affinity are removed from nodes."
  default     = null
}
