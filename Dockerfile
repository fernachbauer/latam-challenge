# Imagen base de Python
FROM python:3.9-slim

# Variables de entorno para evitar prompts de Python
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

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
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
