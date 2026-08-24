#Terraform Modules

Reusable Terraform modules for deploying and managing GCP Cloud Run services, Serverless NEGs, Regional Backend Services, and Regional Internal Load Balancers.

These modules are designed to provide a standardized approach for application infrastructure deployment across GCP projects.

---

# Available Modules

| Module | Purpose | Use When |
|--------|---------|----------|
| `cloudrun` | Creates Cloud Run service | You only need a Cloud Run service |
| `cr-neg-be` | Creates Cloud Run + Serverless NEG + Backend Service | Cloud Run needs to be exposed through a Load Balancer |
| `regional-ilb` | Creates Regional Internal Load Balancer | You need HTTPS/HTTP internal load balancing and routing between backends |

---


# terraform-modules

 Overall module selection guide

 terraform-modules/
│
├── README.md     
│
├── cloudrun/
│   ├── main.tf
│   ├── variables.tf
│   ├── output.tf
│   └── README.md
│
├── cr-neg-be/
│   ├── main.tf
│   ├── variables.tf
│   ├── output.tf
│   └── README.md
│
└── regional-ilb/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── README.md



## Container Image Management

The module provides the Google Cloud Run Hello World image as the default
container image for initial service creation.

The container image is ignored by Terraform after deployment so that
application CI/CD pipelines can independently deploy new container images
without Terraform reverting the service to the default Hello World image.

Terraform manages the Cloud Run infrastructure configuration, while the
application CI/CD pipeline manages container image deployments.

                 Terraform
                    │
                    ▼
          ┌──────────────────┐
          │    Cloud Run     │
          │                  │
          │ Hello World      │ ← Initial bootstrap
          └────────┬─────────┘
                   │
                   │ Developer CI/CD
                   ▼
          ┌──────────────────┐
          │ Application      │
          │ Image v25         │
          └──────────────────┘
