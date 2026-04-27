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

export interface GradeOut {
  id_tarea: number;
  nombre_tarea: string;
  id_bloque: string;
  nota: number;
}

export async function getMyGrades(): Promise<GradeOut[]> {
  return apiFetch<GradeOut[]>('/api/v1/grades/me');
}

export interface AttendanceRecord {
  id_asistencia: number;
  id_alumno: string;
  id_sesion: string;
  fecha: string;
  presente: boolean;
}

export async function getMyAttendance(): Promise<AttendanceRecord[]> {
  return apiFetch<AttendanceRecord[]>('/api/v1/attendance/me');
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
}

export async function sendAgentMessage(
  message: string,
  history: AgentChatMessage[] = [],
): Promise<AgentChatResponse> {
  return authenticatedFetch<AgentChatResponse>(AGENT_URL, '/api/v1/agent/chat', {
    method: 'POST',
    body: JSON.stringify({ message, history }),
  });
}

/** Maps backend rol to frontend userRole stored in localStorage */
export function mapRol(rol: string): string {
  if (rol === 'alumno') return 'student';
  if (rol === 'profesor') return 'professor';
  return 'admin';
}

export interface AgentChatResponse {
  reply: string;
  session_id?: string;
}

export async function sendAgentMessage(message: string, sessionId?: string): Promise<AgentChatResponse> {
  return apiFetch<AgentChatResponse>('/api/v1/agent/chat', {
    method: 'POST',
    body: JSON.stringify({ message, session_id: sessionId }),
  });
}
