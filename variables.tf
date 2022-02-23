variable "namespace" {
  type        = string
  description = "kubernetes namespace where to deploy slo generator"
}

variable "bucket-name" {
  type        = string
  description = "name of the GCS bucket which SLOs will be read from"
}

variable "requests" {
  type        = map(string)
  description = "requests for the api in kubernetes"

  default = {
    cpu    = "50m"
    memory = "50Mi"
  }
}

variable "limits" {
  type        = map(string)
  description = "limits for the api in kubernetes"

  default = {
    cpu    = "50m"
    memory = "50Mi"
  }
}
