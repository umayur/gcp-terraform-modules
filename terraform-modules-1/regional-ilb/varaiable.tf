variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "url_map_name" {
  type = string
}

variable "hostname" {
  type = string
}

variable "default_backend" {
  type = string
}

variable "path_rules" {
  type = map(object({
    paths   = list(string)
    backend = string
  }))

  default = {}
}

variable "https_proxy_name" {
  type = string
}

variable "http_proxy_name" {
  type = string
}

variable "certificate_name_prefix" {
  type = string
}

variable "certificate" {
  type      = string
  sensitive = true
}

variable "private_key" {
  type      = string
  sensitive = true
}

variable "ssl_policy_name" {
  type = string
}

variable "http_redirect_url_map_name" {
  type = string
}

variable "https_forwarding_rule_name" {
  type = string
}

variable "http_forwarding_rule_name" {
  type = string
}

variable "ip_address" {
  type = string
}

variable "subnetwork" {
  type = string
}