resource "google_firestore_database" "default" {
  project     = var.project_id
  name        = "(default)"
  location_id = "australia-southeast1"
  type        = "DATASTORE_MODE"
}

# Create an initial counter entity in Firestore (Datastore mode) using a local-exec provisioner
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

      # Insert entity into Firestore (Datastore mode)
      echo "Inserting entity into Firestore (Datastore mode)..."
      gcloud firestore documents create \
        --project=${var.project_id} \
        --database="(default)" \
        --collection=visitorCounter \
        --document-id=counter \
        --fields=name=counter,count=46

      # Verify insertion
      echo "Listing Firestore documents..."
      gcloud firestore documents list \
        --project=${var.project_id} \
        --database="(default)" \
        --collection-group=visitorCounter
    EOT
  }
}
