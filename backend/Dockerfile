# TODO: Define base image and setup
# 1. Usamos una imagen oficial de Python ligera para que el despliegue sea rápido
FROM python:3.11-slim

# 2. Establecemos el directorio de trabajo dentro del contenedor
WORKDIR /app

# 3. Copiamos primero el requirements.txt
# (Esto optimiza la caché de Docker para no reinstalar todo si solo cambias el código)
COPY requirements.txt .

# 4. Instalamos las dependencias sin guardar la caché temporal para que la imagen pese menos
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copiamos el resto de los archivos de la API (main.py, models.py, etc.)
COPY . .

# 6. Cloud Run usa por defecto el puerto 8080
EXPOSE 8080

# 7. Comando para arrancar el servidor web Uvicorn
# Cloud Run establece la variable de entorno PORT automáticamente
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]

