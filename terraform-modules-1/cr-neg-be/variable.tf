variable "project_id" {}

variable "region" {}

variable "service_name" {}

variable "image" {
  default = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "cpu" {
  default = "1"
}

variable "memory" {
  default = "512Mi"
}

variable "vpc_connector" {
  default = null
}

variable "vpc_egress" {
  default = "ALL_TRAFFIC"
}

variable "env_vars" {
  type    = map(string)
  default = {}
}

variable "enable_iap" {

  type = bool

  default = false

}

variable "backend_protocol" {
  type    = string
  default = "HTTPS"
}

variable "load_balancing_scheme" {
  type    = string
  default = "EXTERNAL_MANAGED"
}

variable "ingress" {
  default = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
}