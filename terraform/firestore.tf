# Firestore database in Datastore mode
resource "google_firestore_database" "default" {
  project     = var.project_id
  name        = "(default)"
  location_id = "australia-southeast1"
  type        = "DATASTORE_MODE"

  delete_protection_state = "DELETE_PROTECTION_DISABLED"
  deletion_policy         = "DELETE"
}

# Insert a document into Firestore (Datastore mode) using a local-exec provisioner
resource "null_resource" "visitor_counter" {
  depends_on = [
    google_firestore_database.default
  ]

  provisioner "local-exec" {
    command = <<EOT
      set -e

      echo "Validating Firestore mode..."
      DB_MODE=$(gcloud firestore databases describe --project=${var.project_id} --format="value(type)")
      if [ "$DB_MODE" != "DATASTORE_MODE" ]; then
        echo "Error: Firestore is not in DATASTORE_MODE. Current mode is $DB_MODE."
        exit 1
      fi

      echo "Inserting document into Firestore (Datastore mode)..."
      gcloud datastore entities insert visitorCounter \
        --project=${var.project_id} \
        --key-path="visitorCounter/counter" \
        --properties="name=counter,count=46"

      echo "Listing Firestore documents..."
      gcloud datastore entities lookup \
        --project=${var.project_id} \
        --keys="visitorCounter/counter"
    EOT
  }
}
