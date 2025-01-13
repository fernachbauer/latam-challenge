# ✅ Creación del Dataset en BigQuery
resource "google_bigquery_dataset" "latam_dataset" {
  dataset_id  = "latam_dataset"
  location    = var.region
  description = "Dataset para almacenar datos de la API LATAM"
}

# 🚀 Despliegue del servicio en Cloud Run
resource "google_cloud_run_service" "latam_api" {
  name     = "latam-api"
  location = var.region

  template {
    spec {
      containers {
        image = var.docker_image

        # 🔐 Se pasa el secreto directamente como variable de entorno
        env {
          name  = "GOOGLE_APPLICATION_CREDENTIALS"
          value = "/tmp/credentials.json"
        }

        # ✅ Comando para crear el archivo de credenciales dentro del contenedor
        command = ["/bin/sh"]
        args    = [
          "-c",
          "echo \"$GCP_KEY\" > /tmp/credentials.json && uvicorn app.main:app --host 0.0.0.0 --port 8080"
        ]

        # 🔍 Proceso de revisión de estado de la API
        liveness_probe {
          http_get {
            path = "/health"
            port = 8080
          }
          initial_delay_seconds = 5
          period_seconds        = 10
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true
}

# 🔓 Permiso para invocar el servicio de Cloud Run públicamente
resource "google_cloud_run_service_iam_member" "invoker" {
  service  = google_cloud_run_service.latam_api.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}
