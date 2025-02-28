# Enable the required GCP services
resource "google_project_service" "enable_apis" {
  for_each = toset(local.apis)
  project  = var.project_id
  service  = each.value
  disable_on_destroy = true
}

# Define the API Gateway API
resource "google_api_gateway_api" "visitor_counter_api" {
  provider   = google-beta
  api_id     = "visitor-counter-api"
  depends_on = [google_project_service.enable_apis["apigateway.googleapis.com"]]
}

# API Gateway API Configuration with safer ID formatting
resource "google_api_gateway_api_config" "visitor_counter_api_config" {
  provider = google-beta
  api      = google_api_gateway_api.visitor_counter_api.api_id

  # Generate a simplified config ID without special characters
  api_config_id = "visitor-counter-config-v${formatdate("YYYYMMDDHHmmss", timestamp())}"

  openapi_documents {
    document {
      path     = "openapi.yaml"
      contents = filebase64("${path.module}/openapi.yaml")
    }
  }

  # Avoid conflicts by creating new config before destroying the old one
  lifecycle {
    create_before_destroy = true
    # Ignore changes to avoid unnecessary updates
    ignore_changes = [
      api_config_id
    ]
  }
}

# Create the API Gateway with dynamic config updates
resource "google_api_gateway_gateway" "visitor_counter_gateway" {
  provider   = google-beta
  gateway_id = "visitor-counter-gateway"
  api_config = google_api_gateway_api_config.visitor_counter_api_config.id

  lifecycle {
    # Ensure the gateway is not destroyed when the config is updated
    prevent_destroy = false
  }

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
