# DataIAProject_3

## Backend DB Bootstrap

- `db/esquema.sql`: esquema canonico usado por el backend actual.
- `db/datos.sql`: seed local con alumnos, profesores, bloques, sesiones, tareas, notas, asistencia y eventos.
- `db/esquema_legacy.sql`: version DBML de referencia.

## Docker Local

Levanta la base de datos, backend, agente y frontend con:

```bash
docker compose up --build
```

URLs locales:

- Frontend: `http://localhost:3000`
- Backend API: `http://localhost:8080`
- Agent API: `http://localhost:8081`
- PostgreSQL: `localhost:5432`, base `edem_hub_db`, usuario `postgres`, password `postgres`

La primera vez que se crea el volumen de Postgres se ejecutan `db/esquema.sql` y
`db/datos.sql`. Si cambias esos SQL y quieres recargar la base desde cero:

```bash
docker compose down -v
docker compose up --build
```
