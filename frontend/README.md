# Frontend

Aplicacion React + Vite desplegada en Cloud Run.

## Build de validacion

```cmd
npm install
npm run build
```

## Despliegue

El frontend se despliega en cloud mediante:

- GitHub Actions: `.github/workflows/deploy-cloud-run.yml`
- despliegue manual: `deploy-frontend.cmd`

El build de cloud recibe estas variables como build args:

- `VITE_BACKEND_URL`
- `VITE_AGENT_URL`
