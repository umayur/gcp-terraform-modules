resource "google_compute_region_url_map" "this" {
  project = var.project_id
  name    = var.url_map_name
  region  = var.region

  default_service = var.default_backend

  host_rule {
    hosts        = [var.hostname]
    path_matcher = "path-matcher"
  }

  path_matcher {
    name            = "path-matcher"
    default_service = var.default_backend

    dynamic "path_rule" {
      for_each = var.path_rules

      content {
        paths   = path_rule.value.paths
        service = path_rule.value.backend
      }
    }
  }
}

############## HTTPS proxy ######################

resource "google_compute_region_target_https_proxy" "this" {
  project = var.project_id
  name    = var.https_proxy_name
  region  = var.region

  url_map = google_compute_region_url_map.this.id

  ssl_certificates = [
    google_compute_region_ssl_certificate.this.self_link
  ]

  ssl_policy = google_compute_region_ssl_policy.this.self_link
}

################## SSL certificate ######################

resource "google_compute_region_ssl_certificate" "this" {
  project     = var.project_id
  region      = var.region
  name_prefix = var.certificate_name_prefix

  certificate = var.certificate
  private_key = var.private_key

  lifecycle {
    create_before_destroy = true
  }
}

#####################  SSL policy #############################
resource "google_compute_region_ssl_policy" "this" {
  project         = var.project_id
  region          = var.region
  name            = var.ssl_policy_name
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"
}

###################### HTTP → HTTPS redirect #########################

resource "google_compute_region_url_map" "http_redirect" {
  project = var.project_id
  region  = var.region
  name    = var.http_redirect_url_map_name

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

resource "google_compute_region_target_http_proxy" "this" {
  project = var.project_id
  region  = var.region
  name    = var.http_proxy_name

  url_map = google_compute_region_url_map.http_redirect.self_link
}

###################### Forwarding rules #########################

resource "google_compute_forwarding_rule" "https" {
  project = var.project_id
  region  = var.region

  name                  = var.https_forwarding_rule_name
  ip_protocol           = "TCP"
  port_range            = "443"
  load_balancing_scheme = "INTERNAL_MANAGED"

  ip_address = var.ip_address
  subnetwork = var.subnetwork

  target = google_compute_region_target_https_proxy.this.id

  allow_global_access = true
}


resource "google_compute_forwarding_rule" "http" {
  project = var.project_id
  region  = var.region

  name                  = var.http_forwarding_rule_name
  ip_protocol           = "TCP"
  port_range            = "80"
  load_balancing_scheme = "INTERNAL_MANAGED"

  ip_address = var.ip_address
  subnetwork = var.subnetwork

  target = google_compute_region_target_http_proxy.this.self_link

  allow_global_access = true
}