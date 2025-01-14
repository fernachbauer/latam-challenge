from fastapi import FastAPI, HTTPException
from google.cloud import bigquery, pubsub_v1
from pydantic import BaseModel
import json
import os

app = FastAPI()

# Inicializar el cliente de BigQuery
bq_client = bigquery.Client()


# Inicializar el cliente de Pub/Sub
publisher = pubsub_v1.PublisherClient()
PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT", "latam-devops-project")
TOPIC_NAME = "datos-topic"
topic_path = publisher.topic_path(PROJECT_ID, TOPIC_NAME)

# Suscripción a Pub/Sub
subscriber = pubsub_v1.SubscriberClient()
subscription_path = subscriber.subscription_path("latam-devops-project", "datos-subscription")

# 📬 Procesar mensajes de Pub/Sub e insertar en BigQuery
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

# 📊 Modelo de datos para POST
class Dato(BaseModel):
    id: str
    contenido: str
    timestamp: str

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


# 📨 NUEVO Endpoint para insertar datos (POST)
@app.post("/datos")
def publicar_datos(dato: Dato):
    try:
        # Convertir el dato a JSON
        mensaje = json.dumps(dato.dict()).encode("utf-8")

        # Publicar mensaje en Pub/Sub
        future = publisher.publish(topic_path, mensaje)
        future.result()  # Esperar a que se publique

        return {"mensaje": "Dato publicado correctamente en Pub/Sub."}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al publicar en Pub/Sub: {e}")