# Firestore (Datastore mode) setup
resource "google_datastore_index" "visitor_counter_index" {
  project = var.project_id

  index_id = "visitorcounter-index"
  kind     = "visitorCounter"

  properties {
    name = "name"
    direction = "ASCENDING"
  }

  properties {
    name = "count"
    direction = "ASCENDING"
  }
}

# Create an initial counter entity
resource "google_project_service" "enable_datastore" {
  project = var.project_id
  service = "datastore.googleapis.com"
}

resource "google_firestore_document" "visitor_counter" {
  project  = var.project_id
  database = "(default)"
  collection = "visitorCounter"
  document_id = "counter"

  fields = {
    name  = jsonencode({"stringValue": "counter"})
    count = jsonencode({"integerValue": "43"})
  }

  depends_on = [google_project_service.enable_datastore]
}
