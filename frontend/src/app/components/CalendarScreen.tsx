import { useEffect, useMemo, useState } from 'react';
import {
  BookOpen,
  BriefcaseBusiness,
  CalendarDays,
  ChevronLeft,
  ChevronRight,
  Clock,
  FileText,
  GraduationCap,
  MapPin,
  Plane,
  Trophy,
  UserRound,
  X,
} from 'lucide-react';
import { useNavigate } from 'react-router';
import { getCalendarEvents, type CalendarEvent } from '../api/client';

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

export function CalendarScreen() {
  const navigate = useNavigate();
  const [events, setEvents] = useState<CalendarEvent[]>([]);
  const [loading, setLoading] = useState(true);
  const [visibleMonth, setVisibleMonth] = useState(() => monthStart(new Date()));
  const [selectedEvent, setSelectedEvent] = useState<CalendarEvent | null>(null);
  const [selectedDayEvents, setSelectedDayEvents] = useState<CalendarEvent[] | null>(null);
  const [userRole, setUserRole] = useState<string | null>(null);

  useEffect(() => {
    setUserRole(localStorage.getItem('userRole'));
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
          <p className="text-gray-400 text-sm text-center py-8">Cargando calendario...</p>
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
                          onClick={() => setSelectedEvent(event)}
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
            className="bg-white rounded-2xl p-5 w-full max-w-md shadow-xl"
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
              <button onClick={() => setSelectedEvent(null)} className="p-1 text-gray-400">
                <X size={20} />
              </button>
            </div>

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
              {selectedEvent.descripcion && (
                <div>
                  <p className="text-xs text-gray-400">Descripción</p>
                  <p className="text-sm text-gray-700">{selectedEvent.descripcion}</p>
                </div>
              )}
            </div>

            {canManageAttendance && selectedEvent.tipo === 'class' && selectedEvent.id_sesion && (
              <button
                onClick={() => navigate(`/sessions/${selectedEvent.id_sesion}/attendance`)}
                className="w-full mt-4 bg-[#008899] text-white py-3 rounded-xl text-sm hover:bg-[#007788] transition-colors"
                style={{ fontWeight: 700 }}
              >
                Pasar asistencia
              </button>
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
