variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
}

variable "image_name" {
  description = "Docker image name for Cloud Run"
  type        = string
  default     = "visitor-counter"
}

variable "service_account" {
  description = "Service account email for Cloud Run invoker"
  type        = string
}