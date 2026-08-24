resource "google_cloud_run_v2_service" "this" {
  provider = google-beta
  project  = var.project_id
  location = var.region
  name = var.service_name
  ingress              = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  default_uri_disabled = true
  deletion_protection = false
  lifecycle {
    prevent_destroy = false

    ignore_changes = [
      template[0].containers[0].image
    ]
  }
  template {
    service_account = "project-service-account@${var.project_id}.iam.gserviceaccount.com"
  dynamic "vpc_access" {
  for_each = var.vpc_connector == null ? [] : [1]
  content {
    connector = var.vpc_connector
    egress    = var.vpc_egress
  }
}
    scaling {
      min_instance_count = 0
      max_instance_count = 10
    }
    containers {
      image = var.image
      ports {
        container_port = 8080
        name = "http1"
      }
      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
        cpu_idle = true
        startup_cpu_boost = true
      }
      dynamic "env" {
        for_each = var.env_vars
        content {
          name = env.key
          value = env.value
        }
      }
    }
  }
  traffic {
    type = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
}