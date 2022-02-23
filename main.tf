locals {
  name        = "slo-generator"
  client_name = concat(local.name, "-client")
  labels      = {
    "app.kubernetes.io/name"       = local.name
    "app.kubernetes.io/component"  = "client"
    "app.kubernetes.io/managed-by" = "terraform-kubernetes-google-slo-generator-client"
    "app.kubernetes.io/version"    = "1.0.0"
  }
}

data "kubernetes_service_account" "slo-generator" {
  metadata {
    name      = local.name
    namespace = var.namespace
  }
}

data "kubernetes_service" "slo-generator" {
  metadata {
    name      = local.name
    namespace = var.namespace
  }
}

resource "kubernetes_cron_job_v1" "slo-generator-client" {
  metadata {
    name      = local.client_name
    namespace = var.namespace
    labels    = local.labels
  }
  spec {
    concurrency_policy            = "Allow"
    failed_jobs_history_limit     = 3
    schedule                      = "* * * * *"
    starting_deadline_seconds     = 30
    successful_jobs_history_limit = 5
    job_template {
      metadata {
        labels = local.labels
        name   = local.client_name
      }
      spec {
        template {
          metadata {
            labels = local.labels
            name   = local.client_name
          }
          spec {
            service_account_name = data.kubernetes_service_account.slo-generator.metadata[0].name
            container {
              name    = local.client_name
              image   = "google/cloud-sdk:latest"
              command = ["bash"]
              args    = [
                "-c",
                "gsutil ls gs://${var.bucket-name} | tr '\n' ';' | curl -X POST -d @- http://${data.kubernetes_service.slo-generator.metadata[0].name}/?batch=true"
              ]
              resources {
                requests = var.requests
                limits   = var.limits
              }
              security_context {
                allow_privilege_escalation = false
                read_only_root_filesystem  = true
              }
            }
          }
        }
      }
    }
  }
}
