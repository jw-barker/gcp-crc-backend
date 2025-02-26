resource "google_cloud_run_service" "visitor_counter" {
  name     = var.image_name
  location = var.region

  template {
    spec {
      containers {
        image = "australia-southeast1-docker.pkg.dev/${var.project_id}/visitor-counter-repo/${var.image_name}"
      }
    }
  }

  traffics {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "allow_service_account" {
  location    = var.region
  service     = google_cloud_run_service.visitor_counter.name
  role        = "roles/run.invoker"
  member      = "serviceAccount:${var.service_account}"
}

resource "google_artifact_registry_repository" "visitor_counter" {
  provider = google
  project  = var.project_id
  location = var.region
  repository_id = "visitor-counter-repo"
  format    = "DOCKER"
}

resource "null_resource" "docker_build_push" {
  provisioner "local-exec" {
    command = <<EOT
      gcloud builds submit --tag australia-southeast1-docker.pkg.dev/${var.project_id}/visitor-counter-repo/${var.image_name} .
    EOT
  }
}