variable "gcp_credentials" {
  description = "Google Cloud credentials JSON (desde GitHub Secret)"
  type        = string
  sensitive   = true
}

variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud Region"
  type        = string
}

variable "docker_image" {
  description = "Docker image for Cloud Run"
  type        = string
}

