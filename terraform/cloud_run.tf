resource "google_cloud_run_service" "visitor_counter" {
  name     = var.image_name
  location = var.region

  template {
    spec {
      containers {
        image = "australia-southeast1-docker.pkg.dev/${var.project_id}/cloud-run-source-deploy/${var.image_name}"
        ports {
          container_port = 8080
          name           = "http1"
        }
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
      }
      service_account_name = var.service_account
      timeout_seconds      = 300
      container_concurrency = 80
    }
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"       = "100"
        "run.googleapis.com/startup-cpu-boost"   = "true"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Allow allUsers to invoke the service (Unauthenticated access)
resource "google_cloud_run_service_iam_member" "allow_all_users" {
  location = var.region
  service  = google_cloud_run_service.visitor_counter.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Allow the service account to invoke the service
resource "google_cloud_run_service_iam_member" "allow_service_account" {
  location = var.region
  service  = google_cloud_run_service.visitor_counter.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${var.service_account}"
}

# Artifact Registry for cloud-run-source-deploy
resource "google_artifact_registry_repository" "cloud_run_source_deploy" {
  project        = var.project_id
  location       = var.region
  repository_id  = "cloud-run-source-deploy"
  format         = "DOCKER"
  description    = "Cloud Run Source Deployments"
  mode           = "STANDARD_REPOSITORY"
}

# 🚀 Build & Push Docker image
resource "null_resource" "docker_build_push" {
  provisioner "local-exec" {
    command = <<EOT
      gcloud builds submit --tag australia-southeast1-docker.pkg.dev/${var.project_id}/cloud-run-source-deploy/${var.image_name} .
    EOT
  }
}