from fastapi import FastAPI, HTTPException
from google.cloud import bigquery
import os
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()

app = FastAPI()

# Inicializar cliente de BigQuery
client = bigquery.Client()

@app.get("/health")
def health_check():
    return {"status": "ok"}

@app.get("/")
def read_root():
    return {"mensaje": "¡La API está funcionando correctamente con BigQuery!"}

@app.get("/datos")
def leer_datos():
    try:
        # Consulta a BigQuery
        query = "SELECT * FROM `latam-devops-project.latam_dataset.datos`"
        query_job = client.query(query)
        resultado = query_job.result()

        # Convertir resultados a lista de diccionarios
        datos = [{"id": row.id, "contenido": row.contenido, "timestamp": row.timestamp} for row in resultado]
        return {"datos": datos}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al consultar BigQuery: {e}")

# ⚠️ Este bloque siempre debe estar al final
if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run("app.main:app", host="0.0.0.0", port=port)
