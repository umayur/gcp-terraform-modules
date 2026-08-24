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

resource "google_compute_region_network_endpoint_group" "this" {

  name    = "${var.service_name}-neg"

  project = var.project_id

  region = var.region

  network_endpoint_type = "SERVERLESS"

  cloud_run {

      service = google_cloud_run_v2_service.this.name

  }

}
resource "google_compute_region_backend_service" "this" {

  provider = google

  name    = "${var.service_name}-backend"
  project = var.project_id
  region  = var.region

  protocol                        = "HTTPS"
  load_balancing_scheme           = "INTERNAL_MANAGED"
  connection_draining_timeout_sec = 0
  description                     = "${var.service_name} backend"

  iap {
    enabled = var.enable_iap
  }

  backend {
    group           = google_compute_region_network_endpoint_group.this.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
  lifecycle {
    ignore_changes = [
      iap
    ]
  }
}