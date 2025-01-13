# Imagen base de Python
FROM python:3.9-slim

# Directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiar dependencias
COPY requirements.txt .

# Instalar dependencias
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el resto de la aplicación
COPY . .

# Exponer el puerto 8080
EXPOSE 8080

# Comando para iniciar la API
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"
