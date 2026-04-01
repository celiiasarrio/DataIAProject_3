# Etapa 1: Construcción (Build)
FROM node:20-alpine AS builder

WORKDIR /app

# Build-time env var for the backend URL (injected by CI/CD)
ARG VITE_BACKEND_URL
ENV VITE_BACKEND_URL=$VITE_BACKEND_URL

# Copiar solo los archivos de dependencias primero (aprovecha la caché de Docker)
COPY package.json ./
RUN npm install

# Copiar el resto del código y construir la aplicación
COPY . .
RUN npm run build

# Etapa 2: Servidor (Producción con Nginx)
FROM nginx:alpine

# Copiar los archivos compilados desde la etapa anterior
COPY --from=builder /app/dist /usr/share/nginx/html

# Cambiar el puerto por defecto de Nginx a 8080 (requerido por Cloud Run por defecto)
# y configurar el fallback hacia index.html para que react-router funcione correctamente
RUN sed -i 's/listen  *[0-9]*/listen 8080/' /etc/nginx/conf.d/default.conf && \
    sed -i '/location \/ {/a \        try_files $uri $uri/ /index.html;' /etc/nginx/conf.d/default.conf

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
