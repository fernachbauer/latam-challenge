# ✅ Creación del Dataset en BigQuery
resource "google_bigquery_dataset" "latam_dataset" {
  dataset_id  = "latam_dataset"
  project     = var.project_id
  location    = var.region
  description = "Dataset para almacenar datos de la API LATAM"
}

# ✅ Creación de la Tabla en BigQuery
resource "google_bigquery_table" "datos" {
  dataset_id = google_bigquery_dataset.latam_dataset.dataset_id
  table_id   = "datos"
  project    = var.project_id

  schema {
    fields = [
      {
        name = "id"
        type = "STRING"
        mode = "REQUIRED"
      },
      {
        name = "contenido"
        type = "STRING"
        mode = "NULLABLE"
      }
    ]
  }
}


# 📩 Configuración de Pub/Sub
resource "google_pubsub_topic" "datos_topic" {
  name    = "datos-topic"
  project = var.project_id
}

resource "google_pubsub_subscription" "datos_subscription" {
  name  = "datos-subscription"
  topic = google_pubsub_topic.datos_topic.name
}

# 🚀 Despliegue del servicio en Cloud Run
resource "google_cloud_run_service" "latam_api" {
  name     = "latam-api"
  location = var.region
  project  = var.project_id

  template {
    spec {
      service_account_name = var.service_account

      containers {
        image = var.docker_image

        command = ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]

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

  traffic {
    percent         = 100
    latest_revision = true
  }

  lifecycle {
    ignore_changes = [
      template[0].spec[0].containers[0].image
    ]
    prevent_destroy = true
  }

  autogenerate_revision_name = true
}

# 🔓 Permiso para invocar el servicio
resource "google_cloud_run_service_iam_member" "invoker" {
  service  = google_cloud_run_service.latam_api.name
  location = var.region
  project  = var.project_id
  role     = "roles/run.invoker"
  member   = "allUsers"
}
