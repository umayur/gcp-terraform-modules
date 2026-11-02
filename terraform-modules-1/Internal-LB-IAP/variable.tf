variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "url_map_name" {
  description = "Regional URL map name"
  type        = string
}

variable "hostname" {
  description = "Legacy single hostname used by the load balancer"
  type        = string
  default     = null
}

variable "host_rules" {
  description = "Hostname routing rules with backend and optional path routing"

  type = map(object({
    hosts   = list(string)
    backend = string

    path_rules = optional(map(object({
      paths   = list(string)
      backend = string
    })), {})
  }))

  default = {}
}

variable "default_backend" {
  description = "Backend key used when no hostname matches"
  type        = string
}

############################################
# Backend Configuration
############################################

variable "backends" {
  description = "Backend services and IAP configuration"

  type = map(object({
    name        = string
    neg_id      = string
    enable_iap  = bool
    description = optional(string)
  }))
}


############################################
# Path Rules
############################################

variable "path_rules" {
  description = "URL path based routing rules"

  type = map(object({
    paths   = list(string)
    backend = string
  }))

  default = {}
}


############################################
# SSL Certificate
############################################


############################################
# SSL Certificates
############################################

variable "certificates" {
  description = "Regional SSL certificates and their matching private keys"

  type = map(object({
    name_prefix = string
    certificate = string
    private_key = string
  }))
}



############################################
# SSL Policy
############################################

variable "ssl_policy_name" {
  description = "Regional SSL policy name"
  type        = string
}

variable "ssl_profile" {
  description = "SSL policy profile"
  type        = string
  default     = "RESTRICTED"
}

variable "min_tls_version" {
  description = "Minimum TLS version"
  type        = string
  default     = "TLS_1_2"
}


############################################
# HTTPS / HTTP Proxy
############################################

variable "https_proxy_name" {
  description = "Regional HTTPS proxy name"
  type        = string
}

variable "http_proxy_name" {
  description = "Regional HTTP proxy name"
  type        = string
}

variable "http_redirect_url_map_name" {
  description = "URL map used for HTTP to HTTPS redirect"
  type        = string
}


############################################
# Forwarding Rules
############################################

variable "https_forwarding_rule_name" {
  description = "HTTPS forwarding rule name"
  type        = string
}

variable "http_forwarding_rule_name" {
  description = "HTTP forwarding rule name"
  type        = string
}

variable "ip_address" {
  description = "Regional internal IP address"
  type        = string
}

variable "subnetwork" {
  description = "Subnetwork for the internal load balancer"
  type        = string
}

variable "allow_global_access" {
  description = "Allow clients from other regions to access the internal load balancer"
  type        = bool
  default     = false
}