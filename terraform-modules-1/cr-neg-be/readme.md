# Architecture
Terraform
    |
    +----------------+
    |                |
    v                v
Cloud Run           NEG
                      |
                      v
                Backend Service

#  Multiple Cloud Run Services :The module can be used with for_each when multiple Cloud Run services are required.

rpa-ui
 ├── Cloud Run
 ├── rpa-ui-neg
 └── rpa-ui-backend

rpa-api
 ├── Cloud Run
 ├── rpa-api-neg
 └── rpa-api-backend

Use this module when:
Cloud Run will be behind a Load Balancer.
You need a Serverless NEG.
You need a Regional Backend Service.
You want the Backend Service ID available to another module.
You want multiple Cloud Run services standardized using for_each.

# sample root module code
module "cloud_run" {
  for_each = local.cloud_runs
  source = "git::https://terraform-modules.git//cloudrun?ref=main"
  project_id   = local.application_project_id
  region        = local.region
  service_name  = each.key
  image         = try(each.value.image, null)
  env_vars      = try(each.value.env_vars, {})
  vpc_connector = try(each.value.vpc_connector, null)
}


locals {
  cloud_runs = {
    api = {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
    ui = {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
    worker = {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }
}
