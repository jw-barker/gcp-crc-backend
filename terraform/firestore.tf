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
      gcloud datastore entities insert visitorCounter --project=${var.project_id} --key-path="visitorCounter/counter" --properties=name=counter,count=46
    EOT
  }
}
