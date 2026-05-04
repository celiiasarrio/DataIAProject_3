const BASE_URL = (import.meta.env.VITE_BACKEND_URL as string) || '';
const AGENT_URL = (import.meta.env.VITE_AGENT_URL as string) || BASE_URL;

function getToken(): string | null {
  return localStorage.getItem('token');
}

async function apiFetch<T>(path: string, options: RequestInit = {}): Promise<T> {
  return authenticatedFetch<T>(BASE_URL, path, options);
}

async function authenticatedFetch<T>(baseUrl: string, path: string, options: RequestInit = {}): Promise<T> {
  const token = getToken();
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
  return res.json() as Promise<T>;
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

export async function uploadProfilePhoto(file: File): Promise<{ url_foto: string }> {
  const token = localStorage.getItem('token');
  const formData = new FormData();
  formData.append('file', file);
  const res = await fetch(`${BASE_URL}/api/v1/users/me/photo`, {
    method: 'PUT',
    headers: token ? { Authorization: `Bearer ${token}` } : {},
    body: formData,
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error((err as { detail?: string }).detail || `HTTP ${res.status}`);
  }
  return res.json();
}

export async function deleteProfilePhoto(): Promise<void> {
  return apiFetch<void>('/api/v1/users/me/photo', { method: 'DELETE' });
}

export interface GradeOut {
  id_tarea: number;
  nombre_tarea: string;
  id_bloque: string;
  nota: number;
}

export interface BlockOut {
  id_bloque: string;
  nombre: string;
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
  id_sesion: string | null;
  aula: string | null;
  id_profesor: string | null;
  fecha_inicio: string;
  fecha_fin: string;
  descripcion: string | null;
}

export async function getCalendarEvents(): Promise<CalendarEvent[]> {
  return apiFetch<CalendarEvent[]>('/api/v1/calendar/events');
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
