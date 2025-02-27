# Firestore database in Datastore mode
resource "google_firestore_database" "default" {
  project     = var.project_id
  name        = "(default)"
  location_id = "australia-southeast1"
  type        = "DATASTORE_MODE"
}

# Create a Datastore entity (compatible with Firestore in Datastore mode)
resource "google_datastore_entity" "visitor_counter" {
  project = var.project_id
  kind    = "visitorCounter"

  # Define the entity key
  key {
    path {
      kind = "visitorCounter"
      name = "counter"  # Document ID equivalent
    }
  }

  # Define the entity properties
  properties = jsonencode({
    name  = { stringValue = "counter" }
    count = { integerValue = 46 }
  })

  depends_on = [
    google_firestore_database.default
  ]
}
