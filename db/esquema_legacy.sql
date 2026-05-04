// LEGACY DBML.
// La fuente de verdad ejecutable vive en db/init_db_v2.sql.

Table alumnos {
  id_alumno varchar [pk]
  nombre varchar
  apellido varchar
  apellido2 varchar [null]
  correo varchar [unique]
  contrasena varchar
  url_foto varchar [null]
  rol varchar
  grupo varchar [null]
}

Table profesores {
  id_profesor varchar [pk]
  nombre varchar
  apellido varchar
  apellido2 varchar [null]
  correo varchar [unique]
  contrasena varchar
  url_foto varchar [null]
  rol varchar
}

Table coordinadores {
  id_coordinador varchar [pk]
  nombre varchar
  apellido varchar
  correo varchar [unique]
  contrasena varchar
  rol varchar
  url_foto varchar [null]
}

Table grupos {
  id_grupo varchar [pk]
  nombre varchar [null]
}

Table bloques {
  id_bloque varchar [pk]
  nombre varchar
}

Table sesiones {
  id_sesion varchar [pk]
  id_bloque varchar [ref: > bloques.id_bloque]
  nombre varchar
  fecha date [null]
  hora_inicio time [null]
  hora_fin time [null]
  edificio varchar [null]
  planta varchar [null]
  aula varchar [null]
}

Table ubicaciones {
  id_ubicacion varchar [pk]
  descripcion varchar
  planta varchar [null]
  aula varchar [null]
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

Table rel_coordinadores_grupos {
  id_coordinador varchar [ref: > coordinadores.id_coordinador]
  id_grupo varchar [ref: > grupos.id_grupo]

  indexes {
    (id_coordinador, id_grupo) [pk]
  }
}

Table tareas {
  id_tarea int [pk, increment]
  id_bloque varchar [ref: > bloques.id_bloque]
  nombre varchar
  fecha date [null]
}

Table rel_alumno_tarea {
  id_alumno varchar [ref: > alumnos.id_alumno]
  id_tarea int [ref: > tareas.id_tarea]
  nota float

  indexes {
    (id_alumno, id_tarea) [pk]
  }
}

Table asistencia {
  id_asistencia int [pk, increment]
  id_alumno varchar [ref: > alumnos.id_alumno]
  id_sesion varchar [ref: > sesiones.id_sesion]
  fecha date [null]
  presente boolean

  indexes {
    (id_alumno, id_sesion) [unique]
  }
}

Table eventos {
  id varchar [pk]
  tipo varchar
  titulo varchar
  id_bloque varchar [ref: > bloques.id_bloque, null]
  id_sesion varchar [ref: > sesiones.id_sesion, null]
  aula varchar [null]
  id_profesor varchar [ref: > profesores.id_profesor, null]
  fecha_inicio timestamp
  fecha_fin timestamp
  descripcion text [null]
}

Table franja_tutoria {
  id varchar [pk]
  id_profesor varchar [ref: > profesores.id_profesor]
  id_bloque varchar [ref: > bloques.id_bloque, null]
  dia_semana int
  hora_inicio time
  hora_fin time
  ubicacion varchar
  disponible boolean
}

Table reservas {
  id varchar [pk]
  id_alumno varchar [ref: > alumnos.id_alumno]
  id_profesor varchar [ref: > profesores.id_profesor]
  id_franja varchar [ref: > franja_tutoria.id]
  fecha date
  notas text [null]
  estado varchar
  fecha_creacion timestamp
}

Table notificaciones {
  id varchar [pk]
  id_usuario varchar
  tipo varchar
  titulo varchar
  mensaje text
  leida boolean
  fecha_creacion timestamp
}

Table configuracion_notificaciones {
  id_usuario varchar [pk]
  avisos_calendario boolean
  avisos_notas boolean
  avisos_asistencia boolean
}

Table correos {
  id varchar [pk]
  id_remitente varchar
  id_destinatario varchar
  asunto varchar
  cuerpo text
  leido boolean
  fecha_envio timestamp
}

Table contenidos {
  id varchar [pk]
  id_bloque varchar [ref: > bloques.id_bloque]
  id_profesor varchar [ref: > profesores.id_profesor]
  titulo varchar
  descripcion text [null]
  tipo varchar
  url text
  fecha_subida timestamp
}
