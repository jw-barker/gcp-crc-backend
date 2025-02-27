# Firestore database in Datastore mode
resource "google_firestore_database" "default" {
  project     = var.project_id
  name        = "(default)"
  location_id = "australia-southeast1"
  type        = "DATASTORE_MODE"
}

# Create a Firestore document in Datastore mode
resource "google_firestore_document" "visitor_counter" {
  project     = var.project_id
  database    = "(default)"
  collection  = "visitorCounter"
  document_id = "counter"

  fields = jsonencode({
    name  = { stringValue = "counter" }
    count = { integerValue = 46 }
  })

  depends_on = [
    google_firestore_database.default
  ]
}
