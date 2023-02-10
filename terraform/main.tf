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

module "service_account" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "~> 4.1.1"
  project_id = "github-terraform-gcp"
  prefix     = "samson-cr"
  names      = ["simple"]
}

module "cloud_run" {
  source = "../"
  service_name          = "ci-cloud-run"
  project_id            = var.project_id
  location              = "asia-southeast1"
  image                 = "us-docker.pkg.dev/cloudrun/container/hello"
  service_account_email = module.service_account.email
}


output "service_url" {
  value = google_cloud_run_service.run_service.status[0].url
}