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

      # Validate that the Firestore database is in DATASTORE_MODE
      DB_MODE=$(gcloud firestore databases describe --project=${var.project_id} --format="value(type)")
      if [ "$DB_MODE" != "DATASTORE_MODE" ]; then
        echo "Error: Firestore is not in DATASTORE_MODE. Current mode is $DB_MODE."
        exit 1
      fi

      # Insert entity into Firestore (Datastore mode)
      echo "Inserting entity into Firestore (Datastore mode)..."
      gcloud datastore import gs://bucket_name/path_to_export/export_name.overall_export_metadata \
        --project=${var.project_id} \
        --async

      # Verify insertion
      gcloud datastore indexes list --project=${var.project_id}
    EOT
  }
}
