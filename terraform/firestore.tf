# Firestore database in Datastore mode
resource "google_firestore_database" "default" {
  project     = var.project_id
  name        = "(default)"
  location_id = "australia-southeast1"
  type        = "DATASTORE_MODE"
}

# Create an entity in Firestore (Datastore mode) using Datastore API
resource "google_datastore_entity" "visitor_counter" {
  project = var.project_id
  kind    = "visitorCounter"

  # Define the entity key (similar to document ID)
  key {
    path {
      kind = "visitorCounter"
      name = "counter"  # Acts as the document ID
    }
  }

  # Define the properties of the entity
  properties = jsonencode({
    name  = { stringValue = "counter" }
    count = { integerValue = 46 }
  })

  depends_on = [
    google_firestore_database.default
  ]
}
