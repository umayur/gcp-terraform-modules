variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "url_map_name" {
  description = "Global URL map name"
  type        = string
}


variable "default_backend" {
  description = "Key of the default backend"
  type        = string
}

############################################
# Hostname Routing
############################################

variable "host_rules" {
  description = "Hostname routing rules with backend and optional path routing"

  type = map(object({
    hosts    = list(string)
    backend  = string

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
  description = "Global backend service configuration"

  type = map(object({

    name = string

    neg_id = string

    enable_iap = bool

    enable_cdn = bool

    protocol = optional(string, "HTTPS")

    port_name = optional(string, "http")

    security_policy = optional(string, null)

    description = optional(string, null)

    connection_draining_timeout_sec = optional(number, 0)

    log_config = optional(object({
      enable      = bool
      sample_rate = number
    }), {
      enable      = false
      sample_rate = 1.0
    })
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
# SSL
############################################

variable "ssl_policy_name" {
  description = "Global SSL policy name"
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
# Google Managed SSL Certificates
############################################

variable "certificates" {
  description = "Google-managed SSL certificates"

  type = map(object({
    name    = string
    domains = list(string)
  }))
}



############################################
# Proxies
############################################
############################################
# Google Managed SSL Certificates
############################################

variable "certificates" {
  description = "Google-managed SSL certificates"

  type = map(object({
    name    = string
    domains = list(string)
  }))
}
variable "https_proxy_name" {
  description = "Global HTTPS target proxy name"
  type        = string
}

variable "http_proxy_name" {
  description = "Global HTTP target proxy name"
  type        = string
}

variable "http_redirect_url_map_name" {
  description = "URL map for HTTP to HTTPS redirect"
  type        = string
}


############################################
# Forwarding Rules
############################################

variable "https_forwarding_rule_name" {
  description = "Global HTTPS forwarding rule name"
  type        = string
}

variable "http_forwarding_rule_name" {
  description = "Global HTTP forwarding rule name"
  type        = string
}


############################################
# Global IP
############################################

variable "address" {
  description = "Existing global static IP address"
  type        = string
}