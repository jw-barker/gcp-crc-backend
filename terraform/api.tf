# Enable the required GCP services
resource "google_project_service" "enable_apis" {
  for_each = toset(local.apis)
  project  = var.project_id
  service  = each.key
  disable_on_destroy = true
}

# Define the API Gateway API
resource "google_api_gateway_api" "visitor_counter_api" {
  provider   = google-beta
  api_id     = "visitor-counter-api"
  depends_on = [google_project_service.enable_apis["apigateway.googleapis.com"]]
}

# API Gateway API Configuration with automatic versioning
resource "google_api_gateway_api_config" "visitor_counter_api_config" {
  provider = google-beta
  api      = google_api_gateway_api.visitor_counter_api.api_id

  # Generate a new config ID for each deployment
  api_config_id = "visitor-counter-config-v${timestamp()}"

  openapi_documents {
    document {
      path     = "openapi.yaml"
      contents = filebase64("${path.module}/openapi.yaml")
    }
  }

  # Avoid conflicts by creating new config before destroying the old one
  lifecycle {
    create_before_destroy = true
  }
}

# Create the API Gateway with dynamic config updates
resource "google_api_gateway_gateway" "visitor_counter_gateway" {
  provider   = google-beta
  gateway_id = "visitor-counter-gateway"
  api_config = google_api_gateway_api_config.visitor_counter_api_config.id

  depends_on = [
    google_api_gateway_api.visitor_counter_api,
    google_api_gateway_api_config.visitor_counter_api_config
  ]
}

# Define the list of required APIs
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
    "firestoredatabase.googleapis.com",     
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
