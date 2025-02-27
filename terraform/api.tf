# Enable the API Gateway service
resource "google_project_service" "enable_apis" {
  for_each = toset(local.apis)
  project  = var.project_id
  service  = each.key
}

# Define the API Gateway API
resource "google_api_gateway_api" "visitor_counter_api" {
  provider    = google-beta
  api_id      = "visitor-counter-api"
  depends_on  = [google_project_service.enable_apis]
}

# API Gateway API Configuration
resource "google_api_gateway_api_config" "visitor_counter_api_config" {
  provider = google-beta
  api      = "projects/${var.project_id}/locations/global/apis/visitor-counter-api"
  openapi_documents {
    document {
      path     = "openapi.yaml"
      contents = filebase64("${path.module}/openapi.yaml")
    }
  }
}

# API Gateway without location (global scope)
resource "google_api_gateway_gateway" "visitor_counter_gateway" {
  provider    = google-beta
  gateway_id  = "visitor-counter-gateway"
  api_config  = google_api_gateway_api_config.visitor_counter_api_config.name

  depends_on = [google_api_gateway_api_config.visitor_counter_api_config]
}

locals {
  apis = [
    "analyticshub.googleapis.com",
    "apigateway.googleapis.com",
    "artifactregistry.googleapis.com",
    "bigquery.googleapis.com",
    "bigqueryconnection.googleapis.com",
    "bigquerydatapolicy.googleapis.com",
    "bigquerymigration.googleapis.com",
    "bigqueryreservation.googleapis.com",
    "bigquerystorage.googleapis.com",
    "cloudapis.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudtrace.googleapis.com",
    "containerregistry.googleapis.com",
    "dataform.googleapis.com",
    "dataplex.googleapis.com",
    "datastore.googleapis.com",
    "firebaserules.googleapis.com",
    "firestore.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "pubsub.googleapis.com",
    "run.googleapis.com",
    "servicecontrol.googleapis.com",
    "servicemanagement.googleapis.com",
    "serviceusage.googleapis.com",
    "sql-component.googleapis.com",
    "storage-api.googleapis.com",
    "storage-component.googleapis.com",
    "storage.googleapis.com"
  ]
}