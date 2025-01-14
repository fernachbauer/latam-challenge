from fastapi import FastAPI, HTTPException
from google.cloud import bigquery, pubsub_v1
import json
import os

app = FastAPI()

# Inicializar el cliente de BigQuery
bq_client = bigquery.Client()

# Inicializar el cliente de Pub/Sub
subscriber = pubsub_v1.SubscriberClient()
subscription_path = subscriber.subscription_path("latam-devops-project", "datos-subscription")

# Función para procesar mensajes de Pub/Sub e insertar en BigQuery
def callback(message):
    try:
        print(f"Mensaje recibido: {message.data}")
        data = json.loads(message.data.decode("utf-8"))

        # Insertar en BigQuery
        table_id = "latam-devops-project.latam_dataset.datos"
        rows_to_insert = [data]

        errors = bq_client.insert_rows_json(table_id, rows_to_insert)
        if errors == []:
            print("Datos insertados correctamente en BigQuery.")
        else:
            print(f"Errores al insertar en BigQuery: {errors}")

        message.ack()

    except Exception as e:
        print(f"Error procesando el mensaje: {e}")
        message.nack()

# Suscribirse al tópico de Pub/Sub
subscriber.subscribe(subscription_path, callback=callback)

@app.get("/health")
def health_check():
    return {"status": "ok"}

@app.get("/datos")
def obtener_datos():
    try:
        query = "SELECT * FROM `latam-devops-project.latam_dataset.datos` ORDER BY timestamp DESC LIMIT 10"
        query_job = bq_client.query(query)
        results = query_job.result()
        datos = [dict(row) for row in results]
        return {"datos": datos}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al consultar BigQuery: {e}")
