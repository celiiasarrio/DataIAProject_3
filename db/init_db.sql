// LEGACY DBML.
// El esquema SQL canónico del backend vive en db/init_db_v2.sql.
// --- Tablas Principales (Entidades) ---

Table alumnos {
  id_alumno varchar [pk] 
  nombre varchar
  apellido varchar
  correo varchar
  contrasena varchar
  url_foto varchar
}

Table profesores {
  id_profesor varchar [pk]
  nombre varchar
  apellido varchar
  correo varchar
  contrasena varchar
  url_foto varchar
}

Table personal_edem {
  id_personal varchar [pk]
  nombre varchar
  apellido varchar
  correo varchar
  contrasena varchar
  rol varchar
  url_foto varchar
}

Table grupos {
  id_grupo varchar [pk]
  nombre varchar
}

Table sesiones {
  id_sesion varchar [pk]
  nombre varchar
}

Table ubicaciones {
  id_ubicacion varchar [pk]
  descripcion varchar [null]
  planta int
  aula varchar
}

// --- Tablas de Relaciones (Cruces) ---

Table rel_profesores_sesiones {
  id_profesor varchar [ref: > profesores.id_profesor]
  id_sesion varchar [ref: > sesiones.id_sesion]
  
  indexes {
    (id_profesor, id_sesion) [pk]
  }
}

Table rel_alumnos_grupos {
  id_alumno varchar [ref: > alumnos.id_alumno]
  id_grupo varchar [ref: > grupos.id_grupo]
  
  indexes {
    (id_alumno, id_grupo) [pk]
  }
}

Table rel_sesiones_grupos {
  id_sesion varchar [ref: > sesiones.id_sesion]
  id_grupo varchar [ref: > grupos.id_grupo]
  
  indexes {
    (id_sesion, id_grupo) [pk]
  }
}

Table rel_personal_grupos {
  id_personal varchar [ref: > personal_edem.id_personal]
  id_grupo varchar [ref: > grupos.id_grupo]
  
  indexes {
    (id_personal, id_grupo) [pk]
  }
}

Table rel_alumno_tarea {
  id_alumno varchar [ref: > alumnos.id_alumno]
  id_tarea int [ref: > tareas.id_tarea]
  nota float [null]
  
  indexes {
    (id_alumno, id_tarea) [pk]
  }
}

// --- Tablas de Funcionalidades Extra de la App ---

Table asistencia {
  id_asistencia int [pk, increment]
  id_alumno varchar [ref: > alumnos.id_alumno]
  id_sesion varchar [ref: > sesiones.id_sesion]
  fecha date
  presente boolean

  indexes {
    (id_alumno, id_sesion, fecha) [unique]
  }
}

Table tareas {
  id_tarea int [pk, increment]
  id_sesion varchar [ref: > sesiones.id_sesion]
  nombre varchar
  descripcion varchar
}
