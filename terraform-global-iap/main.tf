############################################
# Global Backend Services
############################################

resource "google_compute_backend_service" "this" {
  for_each = var.backends

  project = var.project_id
  name    = each.value.name

  protocol = each.value.protocol

  port_name = each.value.port_name

  enable_cdn = each.value.enable_cdn

  connection_draining_timeout_sec = (
    each.value.connection_draining_timeout_sec
  )

  security_policy = each.value.security_policy

  description = each.value.description

  dynamic "iap" {
    for_each = each.value.enable_iap ? [1] : []

    content {
      enabled = true
    }
  }

  log_config {
    enable      = each.value.log_config.enable
    sample_rate = each.value.log_config.sample_rate
  }

  backend {
    group = each.value.neg_id
  }
}



############################################
# Global URL Map
# Supports multiple hostnames and backends
############################################

resource "google_compute_url_map" "this" {
  project = var.project_id
  name   = var.url_map_name

  default_service = google_compute_backend_service.this[
    var.default_backend
  ].self_link

  dynamic "host_rule" {
    for_each = var.host_rules

    content {
      hosts        = host_rule.value.hosts
      path_matcher = "path-matcher-${host_rule.key}"
    }
  }

  dynamic "path_matcher" {
    for_each = var.host_rules

    content {
      name = "path-matcher-${path_matcher.key}"

      default_service = google_compute_backend_service.this[
        path_matcher.value.backend
      ].self_link

      dynamic "path_rule" {
        for_each = coalesce(path_matcher.value.path_rules, {})

        content {
          paths = path_rule.value.paths

          service = google_compute_backend_service.this[
            path_rule.value.backend
          ].self_link
        }
      }
    }
  }
}


############################################
# Global SSL Policy
############################################

resource "google_compute_ssl_policy" "this" {
  project = var.project_id
  name    = var.ssl_policy_name

  profile         = var.ssl_profile
  min_tls_version = var.min_tls_version
}



############################################
# Google Managed SSL Certificates
############################################

resource "google_compute_managed_ssl_certificate" "this" {
  for_each = var.certificates

  project = var.project_id
  name    = each.value.name

  managed {
    domains = each.value.domains
  }
}



############################################
# Global HTTPS Target Proxy
############################################

resource "google_compute_target_https_proxy" "this" {
  project = var.project_id
  name    = var.https_proxy_name

  url_map = google_compute_url_map.this.id

  ssl_certificates = [
    for cert in google_compute_managed_ssl_certificate.this :
    cert.self_link
  ]

  ssl_policy = google_compute_ssl_policy.this.self_link
}



############################################
# HTTP Redirect URL Map
############################################

resource "google_compute_url_map" "http_redirect" {
  project = var.project_id
  name    = var.http_redirect_url_map_name

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}


############################################
# Global HTTP Target Proxy
############################################

resource "google_compute_target_http_proxy" "this" {
  project = var.project_id
  name    = var.http_proxy_name

  url_map = google_compute_url_map.http_redirect.self_link
}


############################################
# HTTPS Forwarding Rule
############################################

resource "google_compute_global_forwarding_rule" "https" {
  project = var.project_id
  name    = var.https_forwarding_rule_name

  ip_protocol = "TCP"
  port_range  = "443"

  load_balancing_scheme = "EXTERNAL_MANAGED"

  target = google_compute_target_https_proxy.this.id

  ip_address = var.address
}


############################################
# HTTP Forwarding Rule
############################################

resource "google_compute_global_forwarding_rule" "http" {
  project = var.project_id
  name    = var.http_forwarding_rule_name

  ip_protocol = "TCP"
  port_range  = "80"

  load_balancing_scheme = "EXTERNAL_MANAGED"

  target = google_compute_target_http_proxy.this.id

  ip_address = var.address
}