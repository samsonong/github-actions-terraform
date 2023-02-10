terraform {
    required_version = ">= 0.12.0"
    required_providers {
        google = {
            source = "hashicorp/google",
            version = "4.39.0"
        }
    }
    backend "gcs" {
        bucket = "to_be_overidden_by_terraform_init"
    }
}

provider "google" {
    project = "github-terraform-gcp"
    region = "asia-southeast1"
}

data "terraform_remote_state" "db_inst" {
    backend = "gcs"
    config = {
        bucket  = "tfstate-nonp"
    }
    workspace = var.infra_namespace == "main" || var.infra_namespace == "pre-main" ? var.infra_namespace : "common-nonprod"
}

resource "google_cloud_run_service" "app_service" {
    depends_on = [null_resource.push_image]
    name = "a-prime-${local.abridged_namespace}"
    location = "asia-southeast1"
    template {
        spec {
            containers {
                image = "gcr.io/google-samples/hello-app:1.0"
            }
        }
    }
    autogenerate_revision_name = true
}

resource "google_cloud_run_service_iam_member" "run_all_users" {
  service  = google_cloud_run_service.run_service.name
  location = google_cloud_run_service.run_service.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "service_url" {
  value = google_cloud_run_service.run_service.status[0].url
}