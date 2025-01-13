# ✅ Creación del Dataset en BigQuery
resource "google_bigquery_dataset" "latam_dataset" {
  dataset_id  = "latam_dataset"
  project     = var.project_id  # 🔄 Variable dinámica para el proyecto
  location    = var.region
  description = "Dataset para almacenar datos de la API LATAM"
}

# 🚀 Despliegue del servicio en Cloud Run
resource "google_cloud_run_service" "latam_api" {
  name     = "latam-api"
  location = var.region
  project  = var.project_id

  template {
    spec {
      # ✅ Cuenta de servicio configurada dinámicamente
      service_account_name = var.service_account

      containers {
        image = var.docker_image

        # ✅ Comando directo para iniciar la aplicación
        command = ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
        
        # 🔍 Liveness Probe para verificar la salud del servicio
        liveness_probe {
          http_get {
            path = "/health"
            port = 8080
          }
          initial_delay_seconds = 10
          period_seconds        = 30
          failure_threshold     = 3
        }
      }
    }
  }

  # 🚦 Configuración del tráfico
  traffic {
    percent         = 100
    latest_revision = true
  }

  # 🔒 Protege recursos existentes y evita destrucción accidental
  lifecycle {
    ignore_changes = [
      template[0].spec[0].containers[0].image  # ⚠️ Ignora cambios de imagen
    ]
    prevent_destroy = true
  }

  autogenerate_revision_name = true
}

# 🔓 Permiso para invocar el servicio de Cloud Run públicamente
resource "google_cloud_run_service_iam_member" "invoker" {
  service  = google_cloud_run_service.latam_api.name
  location = var.region
  project  = var.project_id
  role     = "roles/run.invoker"
  member   = "allUsers"
}
