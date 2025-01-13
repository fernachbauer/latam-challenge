# Imagen base de Python
FROM python:3.9-slim

# Directorio de trabajo
WORKDIR /app

# Copiar dependencias
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar la aplicación
COPY . .

# Exponer el puerto 8080
EXPOSE 8080

# Iniciar la API
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
