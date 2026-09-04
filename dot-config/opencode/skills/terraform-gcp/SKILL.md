---
name: terraform-gcp
description: Infrastructure as Code for Google Cloud Platform using Terraform. Covers compute, storage, networking, IAM, and serverless. Uses Application Default Credentials (ADC) for authentication. Biases towards GCP documentation for resource types and arguments.
references:
  - https://registry.terraform.io/providers/hashicorp/google/latest/docs
  - https://cloud.google.com/docs/authentication/application-default-credentials
---

# Terraform for Google Cloud Platform

Infrastructure as Code for GCP. Application Default Credentials (ADC) for authentication.

## Authentication

### Application Default Credentials (ADC) - Preferred

ADC is the recommended authentication method. Works locally and in CI/CD.

```bash
# Local development - authenticate with your Google account
gcloud auth application-default login

# Set your project
gcloud auth application-default set-project YOUR_PROJECT_ID
```

**How ADC works:**
1. Checks `GOOGLE_APPLICATION_CREDENTIALS` environment variable
2. Checks for user credentials from `gcloud auth application-default login`
3. Checks for attached service account (GCE, Cloud Run, GKE)
4. Falls back to metadata server in GCP environments

### Provider Configuration

```hcl
# versions.tf
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }
}

# provider.tf - ADC authentication (no keys needed)
provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# variables.tf
variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}
```

### When to Use Service Accounts

```hcl
# Only for CI/CD or cross-project access
provider "google" {
  project      = var.project_id
  region       = var.region
  credentials  = file("service-account.json")  # Not recommended for local dev
}

# Better: Use workload identity in GKE or attached service accounts
```

## Project Structure

```
terraform/
├── modules/              # Reusable modules
│   ├── compute/
│   ├── storage/
│   ├── networking/
│   └── iam/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   ├── staging/
│   └── prod/
├── global/               # Shared resources
│   └── iam.tf
├── versions.tf
└── backend.tf
```

## Core Resources

### Compute Engine

```hcl
# modules/compute/main.tf
resource "google_compute_instance" "default" {
  name         = "instance-${var.environment}"
  machine_type = "e2-medium"
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 20
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = var.network_id
    subnetwork = var.subnet_id

    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    startup-script = file("scripts/startup.sh")
  }

  labels = {
    environment = var.environment
    managed-by  = "terraform"
  }

  service_account {
    email  = var.service_account_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  tags = ["http-server", "https-server"]
}

# Static IP
resource "google_compute_global_address" "default" {
  name = "ip-${var.environment}"
}

# Firewall rules
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-${var.environment}"
  network = var.network_id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}
```

### Cloud Storage

```hcl
# modules/storage/main.tf
resource "google_storage_bucket" "default" {
  name          = "${var.project_id}-${var.bucket_name}"
  location      = var.region
  storage_class = "STANDARD"
  force_destroy = var.force_destroy

  uniform_bucket_level_access = true

  versioning {
    enabled = var.enable_versioning
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    environment = var.environment
    managed-by  = "terraform"
  }
}

# IAM binding for bucket
resource "google_storage_bucket_iam_member" "viewer" {
  bucket = google_storage_bucket.default.name
  role   = "roles/storage.objectViewer"
  member = "user:${var.viewer_email}"
}

# Bucket for Terraform state
resource "google_storage_bucket" "terraform_state" {
  name          = "${var.project_id}-terraform-state"
  location      = var.region
  storage_class = "STANDARD"
  force_destroy = false

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}
```

### Cloud SQL

```hcl
# modules/database/main.tf
resource "google_sql_database_instance" "default" {
  name             = "db-${var.environment}"
  database_version = "POSTGRES_15"
  region           = var.region

  deletion_protection = var.environment == "prod"

  settings {
    tier              = var.machine_tier
    availability_type = var.environment == "prod" ? "REGIONAL" : "ZONAL"

    disk_size = var.disk_size
    disk_type = "PD_SSD"

    backup_configuration {
      enabled          = true
      binary_log_enabled = false
      start_time       = "03:00"
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
      require_ssl     = true
    }

    maintenance_window {
      day  = 7
      hour = 3
    }

    database_flags {
      name  = "max_connections"
      value = "100"
    }
  }

  depends_on = [google_service_networking_connection.private]
}

resource "google_sql_database" "default" {
  name     = var.database_name
  instance = google_sql_database_instance.default.name
}

resource "google_sql_user" "default" {
  name     = var.database_user
  instance = google_sql_database_instance.default.name
  password = random_password.database_password.result
}

resource "random_password" "database_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}|:?"
}

# Store password in Secret Manager
resource "google_secret_manager_secret" "database_password" {
  secret_id = "database-password-${var.environment}"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "database_password" {
  secret      = google_secret_manager_secret.database_password.id
  secret_data = random_password.database_password.result
}
```

### Cloud Run

```hcl
# modules/serverless/main.tf
resource "google_cloud_run_v2_service" "default" {
  name     = "service-${var.environment}"
  location = var.region

  template {
    service_account = var.service_account_email

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [var.cloudsql_instance]
      }
    }

    containers {
      image = var.container_image

      ports {
        container_port = 8080
      }

      env {
        name  = "ENVIRONMENT"
        value = var.environment
      }

      env {
        name = "DATABASE_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = var.database_password_secret
            version = "latest"
          }
        }
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }

      resources {
        limits = {
          cpu    = var.cpu_limit
          memory = var.memory_limit
        }
      }
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  labels = {
    environment = var.environment
    managed-by  = "terraform"
  }
}

# Allow unauthenticated access (public API)
resource "google_cloud_run_v2_service_iam_member" "public" {
  count  = var.allow_unauthenticated ? 1 : 0
  project = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
```

### Cloud Functions

```hcl
# modules/functions/main.tf
resource "google_cloudfunctions2_function" "default" {
  name        = "function-${var.function_name}-${var.environment}"
  location    = var.region
  description = var.description

  build_config {
    runtime     = var.runtime
    entry_point = var.entry_point

    source {
      storage {
        bucket = var.source_bucket
        object = var.source_object
      }
    }
  }

  service_config {
    max_instance_count    = var.max_instances
    available_memory      = var.memory
    timeout_seconds       = var.timeout
    service_account_email = var.service_account_email

    environment_variables = merge(
      var.environment_variables,
      {
        ENVIRONMENT = var.environment
      }
    )

    secret_environment_variables {
      key        = "API_KEY"
      project_id = var.project_id
      secret     = var.api_key_secret
      version    = "latest"
    }
  }
}

# Allow public access
resource "google_cloud_run_service_iam_member" "public" {
  count  = var.allow_unauthenticated ? 1 : 0
  location = var.region
  project  = var.project_id
  service  = google_cloudfunctions2_function.default.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
```

### IAM and Service Accounts

```hcl
# modules/iam/main.tf
resource "google_service_account" "default" {
  account_id   = "sa-${var.service_name}-${var.environment}"
  display_name = "${var.service_name} ${var.environment}"
  description  = "Service account for ${var.service_name}"
}

# Grant minimal permissions
resource "google_project_iam_member" "roles" {
  for_each = toset(var.iam_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.default.email}"
}

# Workload Identity binding for GKE
resource "google_service_account_iam_member" "workload_identity" {
  count              = var.enable_workload_identity ? 1 : 0
  service_account_id = google_service_account.default.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_namespace}/${var.k8s_sa_name}]"
}

# Impersonation for CI/CD
resource "google_service_account_iam_member" "impersonation" {
  count              = var.enable_impersonation ? 1 : 0
  service_account_id = google_service_account.default.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${var.ci_cd_sa_email}"
}

# Service account key (avoid if possible, use ADC instead)
resource "google_service_account_key" "default" {
  count              = var.create_key ? 1 : 0
  service_account_id = google_service_account.default.name
}
```

### VPC and Networking

```hcl
# modules/networking/main.tf
resource "google_compute_network" "default" {
  name                    = "vpc-${var.environment}"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "default" {
  name          = "subnet-${var.environment}"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.default.id

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_cidr
  }
}

# Cloud NAT for outbound internet
resource "google_compute_router" "default" {
  name    = "router-${var.environment}"
  region  = var.region
  network = google_compute_network.default.id
}

resource "google_compute_router_nat" "default" {
  name                               = "nat-${var.environment}"
  router                             = google_compute_router.default.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Private service access for Cloud SQL
resource "google_compute_global_address" "private_ip_range" {
  name          = "private-ip-${var.environment}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.default.id
}

resource "google_service_networking_connection" "private" {
  network                 = google_compute_network.default.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
}
```

### Memorystore (Redis)

```hcl
# modules/cache/main.tf
resource "google_redis_instance" "default" {
  name           = "redis-${var.environment}"
  tier           = var.tier
  memory_size_gb = var.memory_size

  region = var.region

  authorized_network = var.network_id

  redis_version = "REDIS_7_0"
  display_name  = "Redis ${var.environment}"

  transit_encryption_mode = "SERVER_AUTHENTICATION"

  labels = {
    environment = var.environment
    managed-by  = "terraform"
  }
}
```

### Secret Manager

```hcl
# modules/secrets/main.tf
resource "google_secret_manager_secret" "default" {
  for_each = var.secrets

  secret_id = each.key

  replication {
    auto {}
  }

  labels = {
    environment = var.environment
  }
}

resource "google_secret_manager_secret_version" "default" {
  for_each = var.secrets

  secret      = google_secret_manager_secret.default[each.key].id
  secret_data = each.value
}

# Grant access to service account
resource "google_secret_manager_secret_iam_member" "access" {
  for_each = var.secrets

  secret_id = google_secret_manager_secret.default[each.key].id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.service_account_email}"
}
```

### Cloud CDN and Load Balancing

```hcl
# modules/loadbalancer/main.tf
resource "google_compute_global_forwarding_rule" "default" {
  name       = "lb-${var.environment}"
  target     = google_compute_target_https_proxy.default.id
  port_range = "443"
  ip_address = google_compute_global_address.default.id
}

resource "google_compute_global_address" "default" {
  name = "lb-ip-${var.environment}"
}

resource "google_compute_target_https_proxy" "default" {
  name             = "proxy-${var.environment}"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

resource "google_compute_url_map" "default" {
  name            = "urlmap-${var.environment}"
  default_service = google_compute_backend_bucket.default.id
}

resource "google_compute_backend_bucket" "default" {
  name        = "backend-${var.environment}"
  bucket_name = var.bucket_name

  enable_cdn = true

  cdn_policy {
    cache_mode                   = "CACHE_ALL_STATIC"
    default_ttl                  = 3600
    max_ttl                      = 86400
    client_ttl                   = 3600
    negative_caching             = true
    signed_url_cache_max_age_sec = 7200
  }
}

resource "google_compute_managed_ssl_certificate" "default" {
  name = "cert-${var.environment}"

  managed {
    domains = [var.domain_name]
  }
}
```

## Backend Configuration

### Remote State

```hcl
# backend.tf
terraform {
  backend "gcs" {
    bucket = "my-project-terraform-state"
    prefix = "terraform/state"
  }
}

# State locking is automatic with GCS backend
```

### Environment Isolation

```hcl
# environments/dev/backend.tf
terraform {
  backend "gcs" {
    bucket = "my-project-terraform-state"
    prefix = "terraform/dev"
  }
}

# environments/prod/backend.tf
terraform {
  backend "gcs" {
    bucket = "my-project-terraform-state"
    prefix = "terraform/prod"
  }
}
```

## Common Patterns

### Multi-Environment

```hcl
# environments/dev/main.tf
module "compute" {
  source = "../../modules/compute"

  project_id  = var.project_id
  environment = "dev"
  region      = var.region
  network_id  = module.networking.network_id
  subnet_id   = module.networking.subnet_id
}

module "storage" {
  source = "../../modules/storage"

  project_id  = var.project_id
  environment = "dev"
  region      = var.region
  bucket_name = "assets"
}

# environments/prod/main.tf - same modules, different variables
module "compute" {
  source = "../../modules/compute"

  project_id  = var.project_id
  environment = "prod"
  region      = var.region
  network_id  = module.networking.network_id
  subnet_id   = module.networking.subnet_id
}
```

### Workload Identity for GKE

```hcl
# Enable Workload Identity on GKE cluster
resource "google_container_cluster" "default" {
  name     = "cluster-${var.environment}"
  location = var.region

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Other cluster config...
}

# Kubernetes service account binding
resource "google_service_account_iam_member" "gke_workload" {
  service_account_id = google_service_account.gke.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_namespace}/${var.k8s_sa_name}]"
}
```

### Cloud SQL Proxy for Local Development

```bash
# Connect to Cloud SQL locally using Cloud SQL Proxy
# Install: https://cloud.google.com/sql/docs/postgres/connect-auth-proxy

# Using ADC - no credentials file needed
cloud-sql-proxy --auto-iam-authn PROJECT_ID:REGION:INSTANCE_NAME

# Connect to database
psql "host=localhost user=postgres dbname=mydb sslmode=disable"
```

## Commands

```bash
# Initialize
terraform init

# Plan
terraform plan -out=tfplan

# Apply
terraform apply tfplan

# Destroy
terraform destroy

# Format
terraform fmt -recursive

# Validate
terraform validate

# State
terraform state list
terraform state show google_compute_instance.default

# Import
terraform import google_compute_instance.existing projects/PROJECT_ID/zones/ZONE/instances/NAME

# Workspace (environment isolation)
terraform workspace new dev
terraform workspace select dev
terraform workspace list

# Output
terraform output
terraform output -json
```

## Best Practices

1. **Use ADC** — Never commit service account keys. Use `gcloud auth application-default login` locally
2. **Remote state** — Always use GCS backend with state locking
3. **State isolation** — Separate state files per environment
4. **Modules** — Create reusable modules for common patterns
5. **Variables** — Use `terraform.tfvars` files per environment
6. **Labels** — Apply consistent labels for cost tracking
7. **Deletion protection** — Enable for production databases
8. **Private networking** — Use private IPs for Cloud SQL, Cloud Run
9. **Secrets** — Use Secret Manager, never hardcode secrets
10. **IAM** — Grant minimal permissions, use service accounts per service

## Common Issues

### ADC Not Working

```bash
# Check ADC configuration
gcloud auth application-default login
gcloud auth application-default set-project YOUR_PROJECT_ID

# Verify
gcloud auth application-default print-access-token
```

### State Lock Issues

```bash
# Force unlock (use carefully)
terraform force-unlock LOCK_ID
```

### Permission Denied

```bash
# Check your roles
gcloud projects get-iam-policy PROJECT_ID

# Grant yourself needed roles
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="user:YOUR_EMAIL" \
  --role="roles/editor"
```
