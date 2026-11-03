output "backend_services" {
  description = "Global backend services"

  value = {
    for key, backend in google_compute_backend_service.this :
    key => backend.self_link
  }
}

output "url_map_id" {
  description = "Global URL map ID"

  value = google_compute_url_map.this.id
}

output "https_proxy_id" {
  description = "Global HTTPS proxy ID"

  value = google_compute_target_https_proxy.this.id
}

output "http_proxy_id" {
  description = "Global HTTP proxy ID"

  value = google_compute_target_http_proxy.this.id
}

output "https_forwarding_rule_id" {
  description = "Global HTTPS forwarding rule ID"

  value = google_compute_global_forwarding_rule.https.id
}

output "http_forwarding_rule_id" {
  description = "Global HTTP forwarding rule ID"

  value = google_compute_global_forwarding_rule.http.id
}

output "ssl_policy_id" {
  description = "Global SSL policy ID"

  value = google_compute_ssl_policy.this.id
}

############################################
# Managed SSL Certificate IDs
############################################

output "managed_ssl_certificate_ids" {
  description = "Map of Google-managed SSL certificate IDs"
  value = {
    for key, cert in google_compute_managed_ssl_certificate.this :
    key => cert.id
  }
}