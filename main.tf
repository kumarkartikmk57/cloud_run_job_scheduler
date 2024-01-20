# Create a VPC network
resource "google_compute_network" "vpc_network" {
  name    = var.vpc_name
  auto_create_subnetworks = false
  project = var.project
}


#resource "google_service_account" "cloud_run_invoker_sa" {
#  account_id   = "cloud-run-invoker"
#  display_name = "Cloud Run Invoker"
#  provider     = google-beta
#  project      = var.project
#}



# Project IAM binding
resource "google_project_iam_binding" "run_invoker_binding" {
  project = var.project
  role    = "roles/run.invoker"
  members = ["serviceAccount:${var.sa}"]
}

resource "google_project_iam_binding" "token_creator_binding" {
  project = var.project
  role    = "roles/iam.serviceAccountTokenCreator"
  members = ["serviceAccount:${var.sa}"]
}

resource "google_cloud_run_v2_job_iam_binding" "binding" {
  project    = var.project
  location   = var.region
  name       = google_cloud_run_v2_job.job.name
  role       = "roles/viewer"
  members    = ["serviceAccount:${var.sa}"]
  depends_on = [resource.google_cloud_run_v2_job.job]
}
# Create a subnet within the VPC
resource "google_compute_subnetwork" "vpc_subnet" {
  name          = var.subnetwork
  ip_cidr_range = var.subnetwork_range
  region        = var.region
  network       = google_compute_network.vpc_network.name
  project = var.project
}

# Create a VPC Access Connector
resource "google_vpc_access_connector" "vpc_connector" {
  name          = var.connector_name
  ip_cidr_range = var.connector_range
  network        = google_compute_network.vpc_network.name
  region        = var.region
  project = var.project
}

# Create a Cloud Run v2 job
resource "google_cloud_run_v2_job" "job" {
  name     = var.job_name
  location = var.region
  project = var.project

  template {
    template {
      containers {
        image = var.image
      }

      vpc_access {
        connector = google_vpc_access_connector.vpc_connector.id
        egress    = "ALL_TRAFFIC"
      }
    }
  }
}


#resource "google_cloud_scheduler_job" "job" {
#  name             = "test-job"
##  description      = "test http job"
#  schedule         = "*/8 * * * *"
#  time_zone        = "Asia/Calcutta"
#  attempt_deadline = "320s"#
#
#  retry_config {
#    retry_count = 1
#  }#

#  http_target {
#    http_method = "POST"
#    uri         = "https://{var.region}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/{var.project}/jobs/{var.job_name}:run"
#  }
#}


resource "google_cloud_scheduler_job" "job" {
  provider         = google-beta
  name             = var.scheduler_name
  description      = "test http job"
  schedule         = var.schedule
  attempt_deadline = "320s"
  region           = var.region
  project          = var.project

  retry_config {
    retry_count = 3
  }

  http_target {
    http_method = "POST"
    uri         = "https://${google_cloud_run_v2_job.job.location}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${var.project}/jobs/${var.job_name}:run"

    oauth_token {
      service_account_email = var.sa
    }
  }
depends_on = [ google_cloud_run_v2_job.job ]
#  depends_on = [resource.google_project_service.cloudscheduler_api, resource.google_cloud_run_v2_job.default, resource.google_cloud_run_v2_job_iam_binding.binding]
}