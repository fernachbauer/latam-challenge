# ✅ Creación del Dataset en BigQuery
resource "google_bigquery_dataset" "latam_dataset" {
  dataset_id                  = "latam_dataset"
  location                    = var.region
  description                 = "Dataset para almacenar datos de la API LATAM"
  default_table_expiration_ms = 2592000000  # 30 días

  labels = {
    environment = "production"
    team        = "devops"
  }
}

# 🚀 Despliegue del servicio en Cloud Run
resource "google_cloud_run_service" "latam_api" {
  name     = "latam-api"
  location = var.region

  template {
    spec {
      containers {
        image = var.docker_image

        env {
          name  = "GOOGLE_APPLICATION_CREDENTIALS"
          value = "/tmp/credentials.json"
        }

        command = ["/bin/sh"]
        args    = ["-c", "echo '${var.gcp_credentials}' > /tmp/credentials.json && uvicorn app.main:app --host 0.0.0.0 --port 8080"]

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

# 🔓 Permiso para invocar el servicio de Cloud Run (solo usuarios autenticados)
resource "google_cloud_run_service_iam_member" "invoker" {
  service  = google_cloud_run_service.latam_api.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allAuthenticatedUsers"
}

