resource "google_project_service" "enable_api_gateway" {
  project = var.project_id
  service = "apigateway.googleapis.com"
}

resource "google_apigateway_api" "visitor_counter_api" {
  api_id = "visitor-counter-api"
  display_name = "visitor-counter-api"
  depends_on = [google_project_service.enable_api_gateway]
}

resource "google_apigateway_api_config" "visitor_counter_api_config" {
  api       = google_apigateway_api.visitor_counter_api.id
  config_id = "visitor-counter-api-config"

  gateway_config {
    backend {
      google_service_account = var.service_account
      path_translation = "APPEND_PATH_TO_ADDRESS"
      address = google_cloud_run_service.visitor_counter.status[0].url
    }
  }

  openapi_documents {
    document {
      path = "${path.module}/openapi.yaml"
    }
  }
}

# Create the Gateway
resource "google_apigateway_gateway" "visitor_counter_gateway" {
  gateway_id   = "visitor-counter-gateway"
  display_name = "visitor-counter-gateway"
  api_config   = google_apigateway_api_config.visitor_counter_api_config.id
  location     = var.region
}