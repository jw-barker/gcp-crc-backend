terraform {
  backend "gcs" {
    bucket = "resume-api-terraform-state"
    prefix = "terraform.tfstate"
  }
}
