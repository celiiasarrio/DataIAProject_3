const BASE_URL = (import.meta.env.VITE_BACKEND_URL as string) || '';
const AGENT_URL = (import.meta.env.VITE_AGENT_URL as string) || BASE_URL;
const GET_CACHE_TTL_MS = 30_000;
const getCache = new Map<string, { expiresAt: number; value: unknown }>();

function getToken(): string | null {
  return localStorage.getItem('token');
}

async function apiFetch<T>(path: string, options: RequestInit = {}): Promise<T> {
  return authenticatedFetch<T>(BASE_URL, path, options);
}

async function authenticatedFetch<T>(baseUrl: string, path: string, options: RequestInit = {}): Promise<T> {
  const token = getToken();
  const method = (options.method || 'GET').toUpperCase();
  const cacheKey = method === 'GET' ? `${baseUrl}${path}:${token || ''}` : '';
  if (cacheKey) {
    const cached = getCache.get(cacheKey);
    if (cached && cached.expiresAt > Date.now()) return cached.value as T;
  }

  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(options.headers as Record<string, string>),
  };
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }
  const res = await fetch(`${baseUrl}${path}`, { ...options, headers });
  if (res.status === 401) {
    localStorage.removeItem('token');
    localStorage.removeItem('userRole');
    localStorage.removeItem('userId');
    localStorage.removeItem('userName');
    window.location.href = '/';
    throw new Error('Unauthorized');
  }
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error((err as { detail?: string }).detail || `HTTP ${res.status}`);
  }
  if (res.status === 204) return undefined as T;
  const data = await res.json() as T;
  if (cacheKey) {
    getCache.set(cacheKey, { expiresAt: Date.now() + GET_CACHE_TTL_MS, value: data });
  } else if (method !== 'GET') {
    getCache.clear();
  }
  return data;
}

export async function login(email: string, password: string): Promise<{ access_token: string; token_type: string }> {
  const body = new URLSearchParams({ username: email, password });
  const res = await fetch(`${BASE_URL}/api/v1/token`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: body.toString(),
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error((err as { detail?: string }).detail || 'Login incorrecto');
  }
  return res.json();
}

export interface UserProfile {
  id: string;
  nombre: string;
  apellido: string;
  correo: string;
  rol: string;
  url_foto: string | null;
}

export async function getMyProfile(): Promise<UserProfile> {
  return apiFetch<UserProfile>('/api/v1/users/me');
}

export function assetUrl(url: string | null | undefined): string {
  if (!url) return '';
  if (url.startsWith('http://') || url.startsWith('https://') || url.startsWith('blob:')) return url;
  return `${BASE_URL}${url}`;
}

async function uploadForm<T>(path: string, formData: FormData, method = 'POST'): Promise<T> {
  const token = getToken();
  const res = await fetch(`${BASE_URL}${path}`, {
    method,
    headers: token ? { Authorization: `Bearer ${token}` } : {},
    body: formData,
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error((err as { detail?: string }).detail || `HTTP ${res.status}`);
  }
  return res.json() as Promise<T>;
}

export async function uploadProfilePhoto(file: File): Promise<UserProfile> {
  const formData = new FormData();
  formData.append('file', file);
  return uploadForm<UserProfile>('/api/profile/me/avatar', formData);
}

export async function deleteProfilePhoto(): Promise<void> {
  return apiFetch<void>('/api/profile/me/avatar', { method: 'DELETE' });
}

export interface ProfileDocument {
  id: string;
  nombre: string;
  tipo: string;
  url: string;
  content_type: string;
  estado: string;
  fecha_subida: string;
}

export interface ProfileFull extends UserProfile {
  estado: string;
  programa_area: string | null;
  grupo: string | null;
  curso_academico: string | null;
  promocion: string | null;
  campus: string | null;
  modalidad: string | null;
  coordinador_asignado: string | null;
  tutor_academico: string | null;
  fecha_inicio: string | null;
  fecha_fin_estimada: string | null;
  departamento_area: string | null;
  asignaturas: string[];
  especialidad: string | null;
  horario_tutorias: string | null;
  disponibilidad_contacto: string | null;
  programas_coordina: string[];
  grupos_asignados: string[];
  area_coordinacion: string | null;
  horario_atencion: string | null;
  permisos_administrativos: string[];
  telefono: string | null;
  ciudad: string | null;
  idioma_preferido: string | null;
  contacto_emergencia: string | null;
  correo_personal: string | null;
  linkedin: string | null;
  github: string | null;
  portfolio: string | null;
  preferencia_contacto: string | null;
  area_interes: string | null;
  stack_tecnologico: string | null;
  experiencia_actual: string | null;
  disponibilidad: string | null;
  preferencia_jornada: string | null;
  cv: { nombre: string | null; url: string | null; fecha_subida: string | null };
  documentos: ProfileDocument[];
  idioma_app: string;
  notificaciones_email: boolean;
  notificaciones_push: boolean;
  visibilidad_profesional: boolean;
  permitir_cv_empleabilidad: boolean;
  permitir_links_profesores: boolean;
  tema: string;
  ultimo_acceso: string | null;
}

export async function getFullProfile(): Promise<ProfileFull> {
  return apiFetch<ProfileFull>('/api/profile/me');
}

export interface DashboardData {
  grades: GradeOut[];
  attendance: AttendanceMetrics | null;
  events: CalendarEvent[];
}

export async function getDashboard(): Promise<DashboardData> {
  return apiFetch<DashboardData>('/api/v1/dashboard/me');
}

export async function updateProfileSection(section: 'personal' | 'contact' | 'professional' | 'preferences', data: Record<string, unknown>): Promise<ProfileFull> {
  return apiFetch<ProfileFull>(`/api/profile/me/${section}`, {
    method: 'PUT',
    body: JSON.stringify(data),
  });
}

export async function uploadProfileCv(file: File): Promise<ProfileFull> {
  const formData = new FormData();
  formData.append('file', file);
  return uploadForm<ProfileFull>('/api/profile/me/cv', formData);
}

export async function deleteProfileCv(): Promise<ProfileFull> {
  return apiFetch<ProfileFull>('/api/profile/me/cv', { method: 'DELETE' });
}

export async function uploadProfileDocument(tipo: string, file: File): Promise<ProfileDocument> {
  const formData = new FormData();
  formData.append('file', file);
  return uploadForm<ProfileDocument>(`/api/profile/me/documents?tipo=${encodeURIComponent(tipo)}`, formData);
}

export async function replaceProfileDocument(id: string, tipo: string, file?: File): Promise<ProfileDocument> {
  const formData = new FormData();
  if (file) formData.append('file', file);
  return uploadForm<ProfileDocument>(`/api/profile/me/documents/${id}?tipo=${encodeURIComponent(tipo)}`, formData, 'PUT');
}

export async function deleteProfileDocument(id: string): Promise<void> {
  return apiFetch<void>(`/api/profile/me/documents/${id}`, { method: 'DELETE' });
}

export async function changeProfilePassword(current_password: string, new_password: string): Promise<{ mensaje: string }> {
  return apiFetch<{ mensaje: string }>('/api/profile/me/security/password', {
    method: 'PUT',
    body: JSON.stringify({ current_password, new_password }),
  });
}

export interface GradeOut {
  id_tarea: number;
  nombre_tarea: string;
  id_bloque: string;
  nota: number | null;
  categoria: string;
  peso: number;
}

export interface BlockOut {
  id_bloque: string;
  nombre: string;
}

export interface ProfessorOut {
  id_profesor: string;
  nombre: string;
  apellido: string;
  correo: string;
}

export interface TaskOut {
  id_tarea: number;
  id_bloque: string;
  nombre: string;
  descripcion: string | null;
  fecha: string | null;
}

export interface GradeRosterRow {
  id_alumno: string;
  nombre: string;
  apellido: string;
  id_tarea: number;
  nombre_tarea: string;
  id_bloque: string;
  nota: number | null;
}

export async function getMyGrades(): Promise<GradeOut[]> {
  return apiFetch<GradeOut[]>('/api/v1/grades/me');
}

export async function getMyBlocks(): Promise<BlockOut[]> {
  return apiFetch<BlockOut[]>('/api/v1/blocks/me');
}

export async function getProfessors(): Promise<ProfessorOut[]> {
  return apiFetch<ProfessorOut[]>('/api/v1/professors');
}

export async function getBlockTasks(blockId: string): Promise<TaskOut[]> {
  return apiFetch<TaskOut[]>(`/api/v1/blocks/${blockId}/tasks`);
}

export async function getTaskGrades(taskId: number): Promise<GradeRosterRow[]> {
  return apiFetch<GradeRosterRow[]>(`/api/v1/grades/tasks/${taskId}`);
}

export async function saveGrade(id_alumno: string, id_tarea: number, nota: number): Promise<void> {
  return apiFetch<void>('/api/v1/grades', {
    method: 'POST',
    body: JSON.stringify({ id_alumno, id_tarea, nota }),
  });
}

export interface AttendanceRecord {
  id_asistencia: number;
  id_alumno: string;
  id_sesion: string;
  fecha: string;
  presente: boolean;
}

export interface AttendanceMetrics {
  total_clases: number;
  clases_asistidas: number;
  porcentaje_asistencia: number;
  faltas: number;
  faltas_permitidas_80: number;
  faltas_restantes_80: number;
  nota_asistencia: number;
  estado: string;
  aviso: string | null;
}

export interface AttendanceRosterRow {
  id_alumno: string;
  nombre: string;
  apellido: string;
  id_sesion: string;
  fecha: string | null;
  presente: boolean | null;
  id_asistencia: number | null;
}

export async function getMyAttendance(): Promise<AttendanceRecord[]> {
  return apiFetch<AttendanceRecord[]>('/api/v1/attendance/me');
}

export async function getMyAttendanceMetrics(): Promise<AttendanceMetrics> {
  return apiFetch<AttendanceMetrics>('/api/v1/attendance/me/metrics');
}

export async function checkInAttendance(id_sesion: string): Promise<AttendanceRecord> {
  return apiFetch<AttendanceRecord>('/api/v1/attendance/me/check-in', {
    method: 'POST',
    body: JSON.stringify({ id_sesion }),
  });
}

export async function getSessionAttendanceRoster(sessionId: string): Promise<AttendanceRosterRow[]> {
  return apiFetch<AttendanceRosterRow[]>(`/api/v1/attendance/sessions/${sessionId}/roster`);
}

export async function saveAttendance(id_alumno: string, id_sesion: string, presente: boolean, fecha?: string | null): Promise<AttendanceRecord> {
  return apiFetch<AttendanceRecord>('/api/v1/attendance', {
    method: 'POST',
    body: JSON.stringify({ id_alumno, id_sesion, presente, fecha }),
  });
}

export interface CalendarEvent {
  id: string;
  tipo: string;
  titulo: string;
  id_bloque: string | null;
  bloque_nombre: string | null;
  id_sesion: string | null;
  aula: string | null;
  edificio: string | null;
  planta: string | null;
  id_profesor: string | null;
  profesor_nombre: string | null;
  fecha_inicio: string;
  fecha_fin: string;
  descripcion: string | null;
}

export async function getCalendarEvents(): Promise<CalendarEvent[]> {
  return apiFetch<CalendarEvent[]>('/api/v1/calendar/events');
}

export interface SessionUpdatePayload {
  id_bloque?: string;
  nombre?: string;
  fecha?: string;
  hora_inicio?: string;
  hora_fin?: string;
  aula?: string;
  edificio?: string;
  planta?: string;
}

export async function updateSession(sessionId: string, payload: SessionUpdatePayload): Promise<void> {
  return apiFetch<void>(`/api/v1/sessions/${sessionId}`, {
    method: 'PUT',
    body: JSON.stringify(payload),
  });
}

export interface CalendarEventUpdatePayload {
  tipo?: string;
  titulo?: string;
  id_bloque?: string;
  aula?: string;
  id_profesor?: string | null;
  fecha_inicio?: string;
  fecha_fin?: string;
  descripcion?: string | null;
}

export async function createCalendarEvent(payload: CalendarEventUpdatePayload): Promise<CalendarEvent> {
  return apiFetch<CalendarEvent>('/api/v1/calendar/events', {
    method: 'POST',
    body: JSON.stringify(payload),
  });
}

export async function updateCalendarEvent(eventId: string, payload: CalendarEventUpdatePayload): Promise<CalendarEvent> {
  return apiFetch<CalendarEvent>(`/api/v1/calendar/events/${eventId}`, {
    method: 'PUT',
    body: JSON.stringify(payload),
  });
}

export async function deleteCalendarEvent(eventId: string): Promise<void> {
  return apiFetch<void>(`/api/v1/calendar/events/${eventId}`, { method: 'DELETE' });
}

export interface ContentOut {
  id: string;
  id_bloque: string;
  id_profesor: string;
  titulo: string;
  descripcion: string | null;
  tipo: string;
  url: string;
  fecha_subida: string;
}

export interface ContentCreatePayload {
  titulo: string;
  descripcion?: string | null;
  tipo: string;
  url: string;
}

export async function getBlockContent(blockId: string): Promise<ContentOut[]> {
  return apiFetch<ContentOut[]>(`/api/v1/blocks/${blockId}/content`);
}

export async function createBlockContent(blockId: string, payload: ContentCreatePayload): Promise<ContentOut> {
  return apiFetch<ContentOut>(`/api/v1/blocks/${blockId}/content`, {
    method: 'POST',
    body: JSON.stringify(payload),
  });
}

export async function deleteContent(contentId: string): Promise<void> {
  return apiFetch<void>(`/api/v1/content/${contentId}`, { method: 'DELETE' });
}

export interface AgentChatMessage {
  role: 'user' | 'assistant';
  content: string;
}

export interface AgentChatResponse {
  reply: string;
  session_id?: string;
}

export interface SendAgentMessageOptions {
  history?: AgentChatMessage[];
  sessionId?: string;
}

export async function sendAgentMessage(
  message: string,
  options: SendAgentMessageOptions = {},
): Promise<AgentChatResponse> {
  const { history = [], sessionId } = options;
  return authenticatedFetch<AgentChatResponse>(AGENT_URL, '/api/v1/agent/chat', {
    method: 'POST',
    body: JSON.stringify({ message, history, session_id: sessionId }),
  });
}

/** Maps backend rol to frontend userRole stored in localStorage */
export function mapRol(rol: string): string {
  if (rol === 'alumno') return 'student';
  if (rol === 'profesor') return 'professor';
  return 'admin';
}
