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

variable "service_account" {
  description = "Cuenta de servicio con permisos necesarios"
  type        = string
}