locals {
  image_pull_secrets = compact(var.image_pull_secret != null
    ? [var.image_pull_secret]
    : []
  )
}

resource "kubernetes_job" "descheduler" {
  metadata {
    name      = format("%s-%s", var.name, "job")
    namespace = var.namespace
  }

  spec {

    parallelism = 1
    completions = 1

    template {
      metadata {
        name = format("%s-%s", var.name, "pod")
        annotations = merge(
          {
            "scheduler.alpha.kubernetes.io/critical-pod" = ""
          },
          var.annotations
        )
      }

      spec {
        container {
          name  = var.name
          image = format("%s:%s", var.image.name, var.image.tag != null ? var.image.tag : "latest")

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

        dynamic "image_pull_secrets" {
          for_each = local.image_pull_secrets

          content {
            name = image_pull_secrets.value
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
