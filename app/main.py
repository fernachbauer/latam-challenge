from fastapi import FastAPI, HTTPException
import psycopg2
from psycopg2 import OperationalError
from dotenv import load_dotenv
import os

# Cargar variables de entorno
load_dotenv()

app = FastAPI()

# Conectar a PostgreSQL
try:
    conn = psycopg2.connect(
        dbname=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        host=os.getenv("DB_HOST"),
        port="5432"
    )
    print("✅ Conectado a la base de datos")
except OperationalError as e:
    print(f"❌ Error de conexión a la base de datos: {e}")
    conn = None

@app.get("/")
def read_root():
    return {"mensaje": "¡La API está funcionando correctamente!"}

@app.get("/datos")
def leer_datos():
    if conn is None:
        raise HTTPException(status_code=500, detail="❌ No hay conexión a la base de datos.")
    
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM datos;")
        resultado = cursor.fetchall()
        cursor.close()
        return {"datos": resultado}
    except Exception as e:
        print(f"❌ Error al consultar la base de datos: {e}")
        raise HTTPException(status_code=500, detail=f"Error al consultar la base de datos: {e}")