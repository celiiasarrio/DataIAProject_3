import { useEffect, useMemo, useState } from 'react';
import {
  BookOpen,
  BriefcaseBusiness,
  CalendarDays,
  ChevronLeft,
  ChevronRight,
  Clock,
  Edit3,
  FileText,
  GraduationCap,
  MapPin,
  Plane,
  Trophy,
  UserRound,
  X,
} from 'lucide-react';
import { useNavigate } from 'react-router';
import {
  getCalendarEvents,
  getMyBlocks,
  getProfessors,
  updateCalendarEvent,
  updateSession,
  type BlockOut,
  type CalendarEvent,
  type ProfessorOut,
} from '../api/client';
import { CenteredLoadingSpinner } from './ui/LoadingSpinner';

const EVENT_META: Record<string, { label: string; icon: React.ElementType; bg: string; text: string; chip: string }> = {
  class: { label: 'Sesión', icon: BookOpen, bg: 'bg-blue-50', text: 'text-blue-700', chip: 'bg-blue-500' },
  delivery: { label: 'Entrega', icon: FileText, bg: 'bg-amber-50', text: 'text-amber-700', chip: 'bg-amber-400' },
  international: { label: 'Experiencia internacional', icon: MapPin, bg: 'bg-lime-50', text: 'text-lime-800', chip: 'bg-lime-500' },
  softSkills: { label: 'Soft skills', icon: UserRound, bg: 'bg-rose-50', text: 'text-rose-700', chip: 'bg-rose-500' },
  tfm: { label: 'TFM', icon: GraduationCap, bg: 'bg-violet-50', text: 'text-violet-700', chip: 'bg-violet-500' },
  hackathon: { label: 'Hackatón', icon: Trophy, bg: 'bg-red-50', text: 'text-red-700', chip: 'bg-red-500' },
  visit: { label: 'Visita', icon: Plane, bg: 'bg-sky-50', text: 'text-sky-700', chip: 'bg-sky-500' },
  employability: { label: 'Empleabilidad', icon: BriefcaseBusiness, bg: 'bg-teal-50', text: 'text-teal-700', chip: 'bg-teal-500' },
};

const WEEK_DAYS = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

const formatMonth = (value: Date) =>
  new Intl.DateTimeFormat('es-ES', { month: 'long', year: 'numeric' }).format(value);

const formatLongDate = (value: string) =>
  new Intl.DateTimeFormat('es-ES', {
    weekday: 'long',
    day: '2-digit',
    month: 'long',
    year: 'numeric',
  }).format(new Date(value));

const formatTime = (value: string) =>
  new Intl.DateTimeFormat('es-ES', {
    hour: '2-digit',
    minute: '2-digit',
  }).format(new Date(value));

const getDayKey = (value: string | Date) => {
  const date = typeof value === 'string' ? new Date(value) : value;
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
};

const toDateInput = (value: string) => getDayKey(value);

const toTimeInput = (value: string) => {
  const date = new Date(value);
  return `${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`;
};

const buildDateTime = (date: string, time: string) => `${date}T${time}:00`;

const monthStart = (date: Date) => new Date(date.getFullYear(), date.getMonth(), 1);
const addMonths = (date: Date, amount: number) => new Date(date.getFullYear(), date.getMonth() + amount, 1);

const buildMonthDays = (visibleMonth: Date) => {
  const first = monthStart(visibleMonth);
  const mondayOffset = (first.getDay() + 6) % 7;
  const gridStart = new Date(first);
  gridStart.setDate(first.getDate() - mondayOffset);

  return Array.from({ length: 42 }, (_, index) => {
    const day = new Date(gridStart);
    day.setDate(gridStart.getDate() + index);
    return day;
  });
};

const getEventDayKeys = (event: CalendarEvent) => {
  const keys: string[] = [];
  const current = new Date(event.fecha_inicio);
  current.setHours(0, 0, 0, 0);
  const end = new Date(event.fecha_fin);
  end.setHours(0, 0, 0, 0);

  while (current.getTime() <= end.getTime()) {
    keys.push(getDayKey(current));
    current.setDate(current.getDate() + 1);
  }

  return keys;
};

const normalizeText = (value: string | null | undefined) =>
  (value ?? '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase();

const getEventMeta = (event: CalendarEvent) => {
  const title = normalizeText(event.titulo);

  if (event.tipo === 'international') return EVENT_META.international;
  if (title.includes('tfm')) return EVENT_META.tfm;
  if (event.id_bloque === '6-MDA' || title.includes('hackaton')) return EVENT_META.hackathon;
  if (title.includes('visita')) return EVENT_META.visit;
  if (
    title.includes('empleabilidad') ||
    title.includes('empleo') ||
    title.includes('speed dating') ||
    title.includes('match & go') ||
    title.includes('charlas empresa')
  ) {
    return EVENT_META.employability;
  }
  if (event.id_bloque === '4-MDA') return EVENT_META.softSkills;
  if (event.tipo === 'delivery') return EVENT_META.delivery;

  return EVENT_META.class;
};

const getEventPrefix = (event: CalendarEvent) => {
  if (event.tipo === 'international') return '';
  if (event.tipo === 'delivery') return '';
  if (event.tipo === 'class') return formatTime(event.fecha_inicio);
  return getEventMeta(event).label;
};

const getEventDisplayTitle = (event: CalendarEvent) =>
  [getEventPrefix(event), event.titulo].filter(Boolean).join(' ');

const formatEventLocation = (event: CalendarEvent): string | null => {
  const planta =
    event.planta?.toLowerCase() === 'baja'
      ? 'Planta baja'
      : event.planta
        ? `Planta ${event.planta}`
        : null;
  return [event.aula, event.edificio, planta].filter(Boolean).join(' · ') || null;
};

const shouldShowEvent = (event: CalendarEvent) => {
  const title = normalizeText(event.titulo);
  if (title.includes('experiencia internacional') && event.tipo !== 'international') return false;
  return event.tipo === 'class' || event.tipo === 'delivery' || event.tipo === 'international';
};

type SessionEditForm = {
  titulo: string;
  id_bloque: string;
  id_profesor: string;
  fecha: string;
  hora_inicio: string;
  hora_fin: string;
  aula: string;
  edificio: string;
  planta: string;
};

const buildSessionEditForm = (event: CalendarEvent): SessionEditForm => ({
  titulo: event.titulo ?? '',
  id_bloque: event.id_bloque ?? '',
  id_profesor: event.id_profesor ?? '',
  fecha: toDateInput(event.fecha_inicio),
  hora_inicio: toTimeInput(event.fecha_inicio),
  hora_fin: toTimeInput(event.fecha_fin),
  aula: event.aula ?? '',
  edificio: event.edificio ?? '',
  planta: event.planta ?? '',
});

export function CalendarScreen() {
  const navigate = useNavigate();
  const [events, setEvents] = useState<CalendarEvent[]>([]);
  const [loading, setLoading] = useState(true);
  const [visibleMonth, setVisibleMonth] = useState(() => monthStart(new Date()));
  const [selectedEvent, setSelectedEvent] = useState<CalendarEvent | null>(null);
  const [selectedDayEvents, setSelectedDayEvents] = useState<CalendarEvent[] | null>(null);
  const [userRole, setUserRole] = useState<string | null>(null);
  const [blocks, setBlocks] = useState<BlockOut[]>([]);
  const [professors, setProfessors] = useState<ProfessorOut[]>([]);
  const [editingSession, setEditingSession] = useState(false);
  const [editForm, setEditForm] = useState<SessionEditForm | null>(null);
  const [editMessage, setEditMessage] = useState<string | null>(null);
  const [savingSession, setSavingSession] = useState(false);

  useEffect(() => {
    const role = localStorage.getItem('userRole');
    setUserRole(role);
    if (role === 'admin') {
      getMyBlocks().then(setBlocks).catch(() => setBlocks([]));
      getProfessors().then(setProfessors).catch(() => setProfessors([]));
    }
    getCalendarEvents()
      .then((data) => {
        const sorted = data
          .filter(shouldShowEvent)
          .sort((a, b) => new Date(a.fecha_inicio).getTime() - new Date(b.fecha_inicio).getTime());
        setEvents(sorted);

        const nextEvent =
          sorted.find((event) => new Date(event.fecha_inicio).getTime() >= Date.now()) ??
          sorted[0];
        if (nextEvent) setVisibleMonth(monthStart(new Date(nextEvent.fecha_inicio)));
      })
      .catch(() => setEvents([]))
      .finally(() => setLoading(false));
  }, []);

  const canManageAttendance = userRole === 'admin';
  const canEditSessions = userRole === 'admin';
  const todayKey = getDayKey(new Date());

  const eventsByDay = useMemo(() => {
    const map = new Map<string, CalendarEvent[]>();
    for (const event of events) {
      for (const key of getEventDayKeys(event)) {
        map.set(key, [...(map.get(key) ?? []), event]);
      }
    }
    return map;
  }, [events]);

  const monthDays = useMemo(() => buildMonthDays(visibleMonth), [visibleMonth]);

  const nextEvent = events.find((event) => new Date(event.fecha_inicio).getTime() >= Date.now());

  const startEditingSession = (event: CalendarEvent) => {
    setEditForm(buildSessionEditForm(event));
    setEditMessage(null);
    setEditingSession(true);
  };

  const cancelEditingSession = () => {
    setEditingSession(false);
    setEditForm(selectedEvent ? buildSessionEditForm(selectedEvent) : null);
    setEditMessage(null);
  };

  const updateEditField = (key: keyof SessionEditForm, value: string) => {
    setEditForm((current) => (current ? { ...current, [key]: value } : current));
  };

  const saveSessionChanges = async () => {
    if (!selectedEvent?.id_sesion || !editForm) return;
    const requiredFields: Array<keyof SessionEditForm> = ['titulo', 'id_bloque', 'fecha', 'hora_inicio', 'hora_fin', 'aula', 'edificio', 'planta'];
    if (requiredFields.some((field) => !editForm[field].trim())) {
      setEditMessage('Completa todos los campos obligatorios.');
      return;
    }
    if (editForm.hora_fin <= editForm.hora_inicio) {
      setEditMessage('La hora de fin debe ser posterior a la hora de inicio.');
      return;
    }

    setSavingSession(true);
    setEditMessage(null);
    try {
      await updateSession(selectedEvent.id_sesion, {
        nombre: editForm.titulo.trim(),
        id_bloque: editForm.id_bloque,
        fecha: editForm.fecha,
        hora_inicio: editForm.hora_inicio,
        hora_fin: editForm.hora_fin,
        aula: editForm.aula.trim(),
        edificio: editForm.edificio.trim(),
        planta: editForm.planta.trim(),
      });
      const updatedEvent = await updateCalendarEvent(selectedEvent.id, {
        titulo: editForm.titulo.trim(),
        id_bloque: editForm.id_bloque,
        id_profesor: editForm.id_profesor || null,
        aula: editForm.aula.trim(),
        fecha_inicio: buildDateTime(editForm.fecha, editForm.hora_inicio),
        fecha_fin: buildDateTime(editForm.fecha, editForm.hora_fin),
      });
      setEvents((current) =>
        current
          .map((event) => (event.id === updatedEvent.id ? updatedEvent : event))
          .filter(shouldShowEvent)
          .sort((a, b) => new Date(a.fecha_inicio).getTime() - new Date(b.fecha_inicio).getTime()),
      );
      setSelectedEvent(updatedEvent);
      setEditingSession(false);
      setEditMessage('Sesión actualizada');
    } catch (error) {
      setEditMessage(error instanceof Error ? error.message : 'No se ha podido guardar la sesión');
    } finally {
      setSavingSession(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#008899] pb-20">
      <div className="px-5 pt-12 pb-5">
        <div className="flex items-center gap-3 mb-5">
          <button onClick={() => navigate(-1)} className="p-1">
            <ChevronLeft className="text-white" size={24} />
          </button>
          <div>
            <h1 className="text-white text-xl" style={{ fontWeight: 600 }}>Calendario</h1>
            <p className="text-white text-xs opacity-80">Sesiones y entregas</p>
          </div>
        </div>

        {nextEvent && (
          <div className="bg-white/15 rounded-2xl p-4">
            <p className="text-white/70 text-xs mb-1">Próximo evento</p>
            <p className="text-white text-base" style={{ fontWeight: 700 }}>{nextEvent.titulo}</p>
            <div className="flex flex-wrap gap-x-4 gap-y-1 mt-2 text-xs text-white/75">
              <span>{formatLongDate(nextEvent.fecha_inicio)}</span>
              <span>{formatTime(nextEvent.fecha_inicio)} - {formatTime(nextEvent.fecha_fin)}</span>
              {nextEvent.profesor_nombre && <span>{nextEvent.profesor_nombre}</span>}
            </div>
          </div>
        )}
      </div>

      <div className="bg-white rounded-t-3xl px-4 pt-5 pb-6 min-h-[70vh]">
        <div className="flex items-center justify-between mb-4 px-1">
          <button
            onClick={() => setVisibleMonth((current) => addMonths(current, -1))}
            className="w-9 h-9 flex items-center justify-center rounded-full bg-gray-100 text-gray-600"
          >
            <ChevronLeft size={18} />
          </button>
          <h2 className="text-[#008899] capitalize" style={{ fontWeight: 800 }}>
            {formatMonth(visibleMonth)}
          </h2>
          <button
            onClick={() => setVisibleMonth((current) => addMonths(current, 1))}
            className="w-9 h-9 flex items-center justify-center rounded-full bg-gray-100 text-gray-600"
          >
            <ChevronRight size={18} />
          </button>
        </div>

        <div className="grid grid-cols-7 mb-1">
          {WEEK_DAYS.map((day) => (
            <div key={day} className="text-center text-xs text-gray-400 py-2">
              {day}
            </div>
          ))}
        </div>

        {loading ? (
          <CenteredLoadingSpinner />
        ) : (
          <div className="grid grid-cols-7 border-t border-l border-gray-100 rounded-xl overflow-hidden">
            {monthDays.map((day) => {
              const key = getDayKey(day);
              const dayEvents = eventsByDay.get(key) ?? [];
              const inMonth = day.getMonth() === visibleMonth.getMonth();
              const isToday = key === todayKey;
              const visibleEvents = dayEvents.slice(0, 3);
              const hiddenCount = Math.max(dayEvents.length - visibleEvents.length, 0);

              return (
                <div
                  key={key}
                  className={`min-h-[104px] border-r border-b p-1.5 ${
                    isToday
                      ? 'bg-gray-100 border-gray-300 ring-1 ring-inset ring-gray-400'
                      : inMonth
                        ? 'bg-white border-gray-100'
                        : 'bg-gray-50 border-gray-100'
                  }`}
                >
                  <div className="flex items-center justify-between mb-1">
                    <span
                      className={`flex h-5 min-w-5 items-center justify-center rounded-full px-1 text-xs ${
                        isToday
                          ? 'bg-gray-700 text-white'
                          : inMonth
                            ? 'text-gray-700'
                            : 'text-gray-300'
                      }`}
                    >
                      {day.getDate()}
                    </span>
                    {dayEvents.length > 0 && (
                      <CalendarDays size={11} className="text-gray-300" />
                    )}
                  </div>

                  <div className="space-y-1">
                    {visibleEvents.map((event) => {
                      const meta = getEventMeta(event);
                      return (
                        <button
                          key={event.id}
                          onClick={() => {
                            setSelectedEvent(event);
                            setEditingSession(false);
                            setEditForm(null);
                            setEditMessage(null);
                          }}
                          className={`w-full rounded-md px-1.5 py-1 text-left ${meta.bg} hover:brightness-95 transition`}
                        >
                          <div className="flex items-center gap-1 min-w-0">
                            <span className={`w-1.5 h-1.5 rounded-full flex-shrink-0 ${meta.chip}`} />
                            <span className={`text-[10px] truncate ${meta.text}`} style={{ fontWeight: 700 }}>
                              {getEventDisplayTitle(event)}
                            </span>
                          </div>
                        </button>
                      );
                    })}
                    {hiddenCount > 0 && (
                      <button
                        onClick={() => setSelectedDayEvents(dayEvents)}
                        className="text-[10px] text-gray-500 px-1 underline"
                      >
                        +{hiddenCount} más
                      </button>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {selectedEvent && (
        <div
          className="fixed inset-0 z-50 bg-black/50 px-4 flex items-center justify-center"
          onClick={() => setSelectedEvent(null)}
        >
          <div
            className="bg-white rounded-2xl p-5 w-full max-w-md shadow-xl max-h-[85vh] overflow-y-auto"
            onClick={(event) => event.stopPropagation()}
          >
            <div className="flex items-start justify-between gap-4 mb-4">
              <div className="flex items-start gap-3 min-w-0">
                {(() => {
                  const meta = getEventMeta(selectedEvent);
                  const Icon = meta.icon;
                  return (
                    <div className={`p-2 rounded-xl ${meta.bg}`}>
                      <Icon size={20} className={meta.text} />
                    </div>
                  );
                })()}
                <div className="min-w-0">
                  <p className="text-xs text-gray-400 uppercase" style={{ fontWeight: 800 }}>
                    {getEventMeta(selectedEvent).label}
                  </p>
                  <h3 className="text-lg text-gray-900 leading-tight" style={{ fontWeight: 800 }}>
                    {selectedEvent.titulo}
                  </h3>
                </div>
              </div>
              <button
                onClick={() => {
                  setSelectedEvent(null);
                  setEditingSession(false);
                  setEditForm(null);
                  setEditMessage(null);
                }}
                className="p-1 text-gray-400"
              >
                <X size={20} />
              </button>
            </div>

            {editingSession && editForm ? (
              <div className="space-y-3 bg-gray-50 rounded-2xl p-4">
                <label className="block">
                  <span className="text-xs text-gray-400">Sesión</span>
                  <input
                    value={editForm.titulo}
                    onChange={(event) => updateEditField('titulo', event.target.value)}
                    className="mt-1 w-full rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#008899]"
                  />
                </label>
                <label className="block">
                  <span className="text-xs text-gray-400">Asignatura / bloque</span>
                  <select
                    value={editForm.id_bloque}
                    onChange={(event) => updateEditField('id_bloque', event.target.value)}
                    className="mt-1 w-full rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#008899]"
                  >
                    <option value="">Selecciona bloque</option>
                    {blocks.map((block) => (
                      <option key={block.id_bloque} value={block.id_bloque}>{block.nombre}</option>
                    ))}
                  </select>
                </label>
                <label className="block">
                  <span className="text-xs text-gray-400">Profesor</span>
                  <select
                    value={editForm.id_profesor}
                    onChange={(event) => updateEditField('id_profesor', event.target.value)}
                    className="mt-1 w-full rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#008899]"
                  >
                    <option value="">Profesor pendiente</option>
                    {professors.map((professor) => (
                      <option key={professor.id_profesor} value={professor.id_profesor}>
                        {professor.nombre} {professor.apellido}
                      </option>
                    ))}
                  </select>
                </label>
                <div className="grid grid-cols-2 gap-3">
                  <label className="block">
                    <span className="text-xs text-gray-400">Fecha</span>
                    <input
                      type="date"
                      value={editForm.fecha}
                      onChange={(event) => updateEditField('fecha', event.target.value)}
                      className="mt-1 w-full rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#008899]"
                    />
                  </label>
                  <label className="block">
                    <span className="text-xs text-gray-400">Aula</span>
                    <input
                      value={editForm.aula}
                      onChange={(event) => updateEditField('aula', event.target.value)}
                      className="mt-1 w-full rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#008899]"
                    />
                  </label>
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <label className="block">
                    <span className="text-xs text-gray-400">Hora inicio</span>
                    <input
                      type="time"
                      value={editForm.hora_inicio}
                      onChange={(event) => updateEditField('hora_inicio', event.target.value)}
                      className="mt-1 w-full rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#008899]"
                    />
                  </label>
                  <label className="block">
                    <span className="text-xs text-gray-400">Hora fin</span>
                    <input
                      type="time"
                      value={editForm.hora_fin}
                      onChange={(event) => updateEditField('hora_fin', event.target.value)}
                      className="mt-1 w-full rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#008899]"
                    />
                  </label>
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <label className="block">
                    <span className="text-xs text-gray-400">Edificio</span>
                    <input
                      value={editForm.edificio}
                      onChange={(event) => updateEditField('edificio', event.target.value)}
                      className="mt-1 w-full rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#008899]"
                    />
                  </label>
                  <label className="block">
                    <span className="text-xs text-gray-400">Planta</span>
                    <input
                      value={editForm.planta}
                      onChange={(event) => updateEditField('planta', event.target.value)}
                      className="mt-1 w-full rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#008899]"
                    />
                  </label>
                </div>
              </div>
            ) : (
              <div className="space-y-3 bg-gray-50 rounded-2xl p-4">
                <div>
                  <p className="text-xs text-gray-400">Asignatura / bloque</p>
                  <p className="text-sm text-gray-800" style={{ fontWeight: 700 }}>
                    {selectedEvent.bloque_nombre ?? selectedEvent.id_bloque ?? 'Sin bloque'}
                  </p>
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <p className="text-xs text-gray-400">Fecha</p>
                    <p className="text-sm text-gray-800 capitalize">{formatLongDate(selectedEvent.fecha_inicio)}</p>
                  </div>
                  <div>
                    <p className="text-xs text-gray-400">Hora</p>
                    <p className="text-sm text-gray-800">
                      {formatTime(selectedEvent.fecha_inicio)} - {formatTime(selectedEvent.fecha_fin)}
                    </p>
                  </div>
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div className="flex items-start gap-2">
                    <UserRound size={15} className="text-gray-400 mt-0.5" />
                    <div>
                      <p className="text-xs text-gray-400">Profesor</p>
                      <p className="text-sm text-gray-800">{selectedEvent.profesor_nombre ?? 'Profesor pendiente'}</p>
                    </div>
                  </div>
                  <div className="flex items-start gap-2">
                    <MapPin size={15} className="text-gray-400 mt-0.5" />
                    <div>
                      <p className="text-xs text-gray-400">Aula</p>
                      <p className="text-sm text-gray-800">{formatEventLocation(selectedEvent) ?? 'Aula pendiente'}</p>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {editMessage && <p className="mt-3 text-center text-sm text-gray-500">{editMessage}</p>}

            {canEditSessions && selectedEvent.tipo === 'class' && selectedEvent.id_sesion && (
              editingSession ? (
                <div className="grid grid-cols-2 gap-2 mt-4">
                  <button
                    onClick={cancelEditingSession}
                    disabled={savingSession}
                    className="w-full bg-gray-100 text-gray-700 py-3 rounded-xl text-sm"
                    style={{ fontWeight: 700 }}
                  >
                    Cancelar
                  </button>
                  <button
                    onClick={saveSessionChanges}
                    disabled={savingSession}
                    className="w-full bg-[#008899] disabled:bg-gray-300 text-white py-3 rounded-xl text-sm hover:bg-[#007788] transition-colors"
                    style={{ fontWeight: 700 }}
                  >
                    {savingSession ? 'Guardando...' : 'Guardar'}
                  </button>
                </div>
              ) : (
                <div className="grid grid-cols-2 gap-2 mt-4">
                  <button
                    onClick={() => startEditingSession(selectedEvent)}
                    className="w-full bg-gray-100 text-gray-700 py-3 rounded-xl text-sm flex items-center justify-center gap-2"
                    style={{ fontWeight: 700 }}
                  >
                    <Edit3 size={15} />
                    Editar
                  </button>
                  {canManageAttendance && (
                    <button
                      onClick={() => navigate(`/sessions/${selectedEvent.id_sesion}/attendance`)}
                      className="w-full bg-[#008899] text-white py-3 rounded-xl text-sm hover:bg-[#007788] transition-colors"
                      style={{ fontWeight: 700 }}
                    >
                      Pasar asistencia
                    </button>
                  )}
                </div>
              )
            )}
          </div>
        </div>
      )}

      {selectedDayEvents && (
        <div
          className="fixed inset-0 z-50 bg-black/50 px-4 flex items-center justify-center"
          onClick={() => setSelectedDayEvents(null)}
        >
          <div
            className="bg-white rounded-2xl p-5 w-full max-w-md shadow-xl max-h-[80vh] overflow-y-auto"
            onClick={(event) => event.stopPropagation()}
          >
            <div className="flex items-center justify-between mb-4">
              <div>
                <p className="text-xs text-gray-400 uppercase" style={{ fontWeight: 800 }}>
                  Eventos del día
                </p>
                <h3 className="text-lg text-gray-900 capitalize" style={{ fontWeight: 800 }}>
                  {formatLongDate(selectedDayEvents[0].fecha_inicio)}
                </h3>
              </div>
              <button onClick={() => setSelectedDayEvents(null)} className="p-1 text-gray-400">
                <X size={20} />
              </button>
            </div>

            <div className="space-y-2">
              {selectedDayEvents.map((event) => {
                const meta = getEventMeta(event);
                return (
                  <button
                    key={event.id}
                    onClick={() => {
                      setSelectedDayEvents(null);
                      setSelectedEvent(event);
                      setEditingSession(false);
                      setEditForm(null);
                      setEditMessage(null);
                    }}
                    className={`w-full rounded-xl px-3 py-3 text-left ${meta.bg}`}
                  >
                    <p className={`text-sm ${meta.text}`} style={{ fontWeight: 800 }}>
                      {getEventDisplayTitle(event)}
                    </p>
                    <p className="text-xs text-gray-500 mt-1">
                      {[event.profesor_nombre, formatEventLocation(event)].filter(Boolean).join(' · ')}
                    </p>
                  </button>
                );
              })}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
