// LEGACY DBML.
// El esquema SQL canónico del backend vive en db/init_db_v2.sql.

Table alumnos {
  id_alumno varchar [pk]
  nombre varchar
  apellido1 varchar
  apellido2 varchar [null]
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

Table bloques {
  id_bloque varchar [pk]
  nombre varchar
}

Table sesiones {
  id_sesion varchar [pk]
  id_bloque varchar [ref: > bloques.id_bloque]
  nombre varchar
  fecha date
  hora_inicio time
  hora_fin time
  aula varchar
}

Table ubicaciones {
  id_ubicacion varchar [pk]
  descripcion varchar [null]
  planta int
  aula varchar
}

Table rel_profesores_bloques {
  id_profesor varchar [ref: > profesores.id_profesor]
  id_bloque varchar [ref: > bloques.id_bloque]

  indexes {
    (id_profesor, id_bloque) [pk]
  }
}

Table rel_alumnos_grupos {
  id_alumno varchar [ref: > alumnos.id_alumno]
  id_grupo varchar [ref: > grupos.id_grupo]

  indexes {
    (id_alumno, id_grupo) [pk]
  }
}

Table rel_bloques_grupos {
  id_bloque varchar [ref: > bloques.id_bloque]
  id_grupo varchar [ref: > grupos.id_grupo]

  indexes {
    (id_bloque, id_grupo) [pk]
  }
}

Table rel_personal_grupos {
  id_personal varchar [ref: > personal_edem.id_personal]
  id_grupo varchar [ref: > grupos.id_grupo]

  indexes {
    (id_personal, id_grupo) [pk]
  }
}

Table tareas {
  id_tarea int [pk, increment]
  id_bloque varchar [ref: > bloques.id_bloque]
  nombre varchar
  descripcion varchar
}

Table rel_alumno_tarea {
  id_alumno varchar [ref: > alumnos.id_alumno]
  id_tarea int [ref: > tareas.id_tarea]
  nota float [null]

  indexes {
    (id_alumno, id_tarea) [pk]
  }
}

Table asistencia {
  id_asistencia int [pk, increment]
  id_alumno varchar [ref: > alumnos.id_alumno]
  id_sesion varchar [ref: > sesiones.id_sesion]
  fecha date
  presente boolean

  indexes {
    (id_alumno, id_sesion) [unique]
  }
}

Table contenidos {
  id varchar [pk]
  id_bloque varchar [ref: > bloques.id_bloque]
  id_profesor varchar [ref: > profesores.id_profesor]
  titulo varchar
  descripcion varchar [null]
  tipo varchar
  url varchar
  fecha_subida timestamp
}
