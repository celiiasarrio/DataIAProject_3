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
  url_foto varchar
}

Table personal_edem {
  id_personal varchar [pk]
  nombre varchar
  apellido varchar
  correo varchar
  rol varchar
  url_foto varchar
}

Table grupos {
  id_grupo varchar [pk]
  nombre varchar
}

Table asignaturas {
  id_asignatura varchar [pk]
  nombre varchar
}

Table ubicaciones {
  id_ubicacion varchar [pk]
  descripcion varchar [null]
  planta int
  aula varchar
}

// --- El Motor del Calendario ---

Table sesiones {
  id_sesion int [pk, increment]
  fecha date
  hora_inicio time
  hora_fin time
  id_ubicacion varchar [ref: > ubicaciones.id_ubicacion]
  id_asignatura varchar [ref: > asignaturas.id_asignatura]
  id_profesor varchar [ref: > profesores.id_profesor]
  descripcion varchar [null]
}

// --- Tablas de Relaciones (Cruces) ---

Table rel_profesores_asignaturas {
  id_profesor varchar [ref: > profesores.id_profesor]
  id_asignatura varchar [ref: > asignaturas.id_asignatura]
  
  indexes {
    (id_profesor, id_asignatura) [pk]
  }
}

Table rel_alumnos_grupos {
  id_alumno varchar [ref: > alumnos.id_alumno]
  id_grupo varchar [ref: > grupos.id_grupo]
  
  indexes {
    (id_alumno, id_grupo) [pk]
  }
}

Table rel_asignaturas_grupos {
  id_asignatura varchar [ref: > asignaturas.id_asignatura]
  id_grupo varchar [ref: > grupos.id_grupo]
  
  indexes {
    (id_asignatura, id_grupo) [pk]
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
  id_sesion int [ref: > sesiones.id_sesion]
  presente boolean
}

Table tareas {
  id_tarea int [pk, increment]
  id_asignatura varchar [ref: > asignaturas.id_asignatura]
  nombre varchar
  descripcion varchar
}