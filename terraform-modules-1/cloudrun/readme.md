# Which Module Should I Use?

## 1. `cloudrun`

Use the `cloudrun` module when you only need to create a Cloud Run service.

This module creates:

- Cloud Run v2 service
- Container configuration
- Environment variables
- Optional VPC connector
- Scaling configuration
- CPU and memory configuration
- Cloud Run traffic configuration

### Architecture

    Terraform
        |
        v
    Cloud Run


### Architecture Use this module when:

You only need Cloud Run.
Cloud Run is accessed directly.
Another team/application manages the Load Balancer.
You do not need a Serverless NEG or Backend Service created by this module.

# sample root module code
### Example
module "cloud_run" {
  source = "git::https://github.com/Engage-Cloud-Delivery/terraform-modules.git//cloudrun?ref=main"
  project_id = local.application_project_id
  region = local.region
  service_name = "test-prod"
  #vpc_connector = tolist(module.serverless_connector-prod.connector_ids)[0]
  env_vars = {
    ENVIRONMENT = "prod"
  }
}
