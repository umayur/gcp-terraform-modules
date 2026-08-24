variable "project_id" {}

variable "region" {}

variable "service_name" {}

variable "image" {
  description = "Default Container image to deploy"
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "cpu" {
  default = "1"
}

variable "memory" {
  default = "512Mi"
}

variable "vpc_connector" {
  description = "Optional VPC Connector"
  type        = string
  default     = null
}

variable "vpc_egress" {
  description = "VPC egress setting"
  type        = string
  default     = "ALL_TRAFFIC"
}

variable "env_vars" {
  type    = map(string)
  default = {}
}