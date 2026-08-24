# Architecture

Cloud Run
    |
   NEG
    |
Backend Service
    |
    +------------------+
                       |
                       v
                Regional ILB
                       |
                 URL Map
                  /     \
                 /       \
            UI Backend  API Backend
                 |
              Clients


This module creates the Load Balancer components required to expose backend services through an internal hostname.

The module supports:

Regional URL Map
Host rules
Path-based routing
Regional HTTPS Proxy
Regional SSL Certificate
Regional SSL Policy
HTTP-to-HTTPS redirect
Regional HTTP Proxy
HTTPS forwarding rule
HTTP forwarding rule


# sample root module code

module "internal_ilb" {
  source = "git::https://terraform-modules.git//regional-ilb?ref=main"

  project_id = local.application_project_id
  region     = local.region

  url_map_name = "rpa-ilb-map"

  hostname = "rpa-monitoring-dashboard-dev.ttec.com"

  default_backend = module.cloud_run["rpa-ui"].backend_id

  path_rules = {
    api = {
      paths   = ["/api/*"]
      backend = module.cloud_run["rpa-api"].backend_id
    }
  }

  certificate_name_prefix = "rpa-cert"

  certificate = data.google_secret_manager_secret_version.rpa_ssl_cert.secret_data

  private_key = data.google_secret_manager_secret_version.rpa_ssl_key.secret_data

  ssl_policy_name = "rpa-np-ssl-policy"

  https_proxy_name = "rpa-np-ilb-proxy"

  http_proxy_name = "rpa-http-proxy"

  http_redirect_url_map_name = "ilb-https-redirect"

  https_forwarding_rule_name = "rpa-np-https-forwarding-rule"

  http_forwarding_rule_name = "rpa-np-http-forwarding-rule"

  ip_address = data.google_compute_address.rpa_ip.address

  subnetwork = google_compute_subnetwork.sub-use4-rpa-np.self_link
}
