variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
}

variable "bucket_name" {
  description = "The name of the Cloud Storage bucket"
  type        = string
}

variable "bucket_location" {
  description = "The location of the Cloud Storage bucket"
  type        = string
}

variable "static_ip" {
  description = "The static external IP address for the Load Balancer"
  type        = string
}

variable "ssl_domains" {
  description = "List of domains for the managed SSL certificate"
  type        = list(string)
}

variable "dns_records" {
  description = "Map of DNS records for the domain"
  type        = map(string)
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