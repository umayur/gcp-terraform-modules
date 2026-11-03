
---

# 1. `global-external-lb-serverless/README.md`

Now the external module.

```markdown
# Global External Load Balancer - Serverless

This Terraform module creates a **Global External Application Load Balancer** for GCP serverless workloads such as Cloud Run.

The module supports:

- Global External Managed Load Balancer
- Global backend services
- Serverless NEGs
- Identity-Aware Proxy (IAP)
- Cloud Armor security policies
- Cloud CDN enable/disable
- URL/path-based routing
- Google-managed SSL certificates
- Global SSL policy
- HTTPS
- HTTP to HTTPS redirect
- Existing global static IP
- Single or multiple backend services

The module does **not** create Cloud Run services or Serverless NEGs. These resources are expected to be created separately and their NEG IDs are passed to this module.

---

# Architecture

```text
                         Internet
                            |
                            |
                     Global Static IP
                            |
                  +---------+---------+
                  |                   |
                HTTPS                 HTTP
                  |                   |
                  v                   v
            HTTPS Proxy          HTTP Proxy
                  |                   |
                  |              HTTPS Redirect
                  |                   |
                  v                   |
               URL Map <-------------+
                  |
        +---------+---------+
        |                   |
     /api/*                 /*
        |                   |
        v                   v
   API Backend          UI Backend
      |                     |
     IAP                   IAP
      |                     |
 Cloud Armor            Cloud Armor
      |                     |
 Serverless NEG       Serverless NEG
      |                     |
 Cloud Run              Cloud Run

module "external_lb" {
  source = "git::https://github.com/Engage-Cloud-Delivery/terraform-modules.git//Global-iap?ref=main"
  project_id = local.application_project_id
  url_map_name = "global-url-map"
  hostname = "account-intelligence.ttec.com"
  default_backend = "catalyst-prod"
  backends = {
    catalyst-prod = {
      name       = "catalyst-prod-backend"
      neg_id = google_compute_region_network_endpoint_group.project-catalyst-prod-neg.id
      enable_iap = true
      enable_cdn = false
      protocol  = "HTTPS"
      port_name = "http"
      security_policy = module.security_policy.policy.self_link
      description = "Catalyst production backend"
      connection_draining_timeout_sec = 0

      log_config = {
        enable      = false
        sample_rate = 1.0
      }
    }
  }

  managed_ssl_certificate_domains = [
    "account-intelligence.ttec.com"
  ]
  certificate_name = "account-intelligence-cert"
  ssl_policy_name = "global-ssl-policy"
  ssl_profile = "RESTRICTED"
  min_tls_version = "TLS_1_2"
  https_proxy_name = "catalyst-https-proxy"
  http_proxy_name = "catalyst-http-proxy"
  http_redirect_url_map_name = "catalyst-http-redirect"
  https_forwarding_rule_name = "catalyst-https-forwarding-rule"
  http_forwarding_rule_name = "catalyst-http-forwarding-rule"
  address = data.google_compute_global_address.external-ip.address
}


multi DNS 


module "global_external_lb" {
  source = "git::https://github.com/Engage-Cloud-Delivery/terraform-modules.git//global-external-lb-serverless?ref=main"

  project_id  = local.application_project_id
  url_map_name = "chartofaccounts-global-map"

  default_backend = "api"

  host_rules = {
    dev = {
      hosts   = ["chartofaccounts-dev.ttec.com"]
      backend = "api"
      path_rules = {}
    }

    qa = {
      hosts   = ["chartofaccounts-qa.ttec.com"]
      backend = "qa"
      path_rules = {}
    }
  }

  certificates = {
    dev = {
      name    = "chartofaccounts-dev-managed-cert"
      domains = ["chartofaccounts-dev.ttec.com"]
    }

    qa = {
      name    = "chartofaccounts-qa-managed-cert"
      domains = ["chartofaccounts-qa.ttec.com"]
    }
  }

  # Existing backend configuration
  backends = {
    api = {
      name        = "chartofaccounts-api-backend"
      neg_id      = google_compute_global_network_endpoint_group.chartofaccounts-dev-neg.id
      protocol    = "HTTPS"
      port_name   = "https"
      enable_cdn  = false
      enable_iap   = true
      security_policy = null
      description = "Chart of Accounts Dev backend"

      connection_draining_timeout_sec = 0

      log_config = {
        enable      = true
        sample_rate = 1.0
      }
    }

    qa = {
      name        = "chartofaccounts-qa-backend"
      neg_id      = google_compute_global_network_endpoint_group.chartofaccounts-qa-neg.id
      protocol    = "HTTPS"
      port_name   = "https"
      enable_cdn  = false
      enable_iap   = true
      security_policy = null
      description = "Chart of Accounts QA backend"

      connection_draining_timeout_sec = 0

      log_config = {
        enable      = true
        sample_rate = 1.0
      }
    }
  }

  # Remaining existing inputs:
  ssl_policy_name = "chartofaccounts-global-ssl-policy"
  ssl_profile     = "RESTRICTED"
  min_tls_version = "TLS_1_2"

  https_proxy_name = "chartofaccounts-global-https-proxy"
  http_proxy_name  = "chartofaccounts-global-http-proxy"

  http_redirect_url_map_name = "chartofaccounts-global-http-redirect"

  https_forwarding_rule_name = "chartofaccounts-global-https"
  http_forwarding_rule_name  = "chartofaccounts-global-http"

  address = google_compute_global_address.chartofaccounts_global_lb.address
}