import {
  Bell,
  BookOpen,
  CalendarDays,
  ChevronRight,
  Clock,
  FileText,
  MapPin,
  TrendingUp,
  Trophy,
  UserRound,
  Plane,
  GraduationCap,
  BriefcaseBusiness,
} from 'lucide-react';
import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router';
import {
  getCalendarEvents,
  getMyAttendanceMetrics,
  getMyGrades,
  type AttendanceMetrics,
  type CalendarEvent,
  type GradeOut,
} from '../api/client';

const EVENT_META: Record<string, { label: string; icon: React.ElementType; color: string; bg: string }> = {
  class:         { label: 'Sesión',         icon: BookOpen,          color: 'text-blue-600',   bg: 'bg-blue-100'   },
  international: { label: 'Internacional',   icon: Plane,             color: 'text-lime-600',   bg: 'bg-lime-100'   },
  delivery:      { label: 'Entrega',         icon: FileText,          color: 'text-amber-600',  bg: 'bg-amber-100'  },
  tfm:           { label: 'TFM',             icon: GraduationCap,     color: 'text-violet-600', bg: 'bg-violet-100' },
  hackathon:     { label: 'Hackatón',        icon: Trophy,            color: 'text-red-600',    bg: 'bg-red-100'    },
  softSkills:    { label: 'Soft skills',     icon: UserRound,         color: 'text-rose-600',   bg: 'bg-rose-100'   },
  visit:         { label: 'Visita',          icon: Plane,             color: 'text-sky-600',    bg: 'bg-sky-100'    },
  employability: { label: 'Empleabilidad',   icon: BriefcaseBusiness, color: 'text-teal-600',   bg: 'bg-teal-100'   },
};

const getDayKey = (value: string | Date) => {
  const d = typeof value === 'string' ? new Date(value) : value;
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
};

const formatTime = (value: string) =>
  new Intl.DateTimeFormat('es-ES', { hour: '2-digit', minute: '2-digit' }).format(new Date(value));

const formatShortDate = (value: string) =>
  new Intl.DateTimeFormat('es-ES', { weekday: 'short', day: 'numeric', month: 'short' }).format(new Date(value));

function daysFromNow(dateStr: string) {
  const target = new Date(dateStr);
  target.setHours(0, 0, 0, 0);
  const now = new Date();
  now.setHours(0, 0, 0, 0);
  return Math.ceil((target.getTime() - now.getTime()) / 86_400_000);
}

function DeadlineBadge({ days }: { days: number }) {
  if (days === 0) return <span className="text-xs font-semibold px-2 py-0.5 rounded-full bg-red-100 text-red-700">Hoy</span>;
  if (days === 1) return <span className="text-xs font-semibold px-2 py-0.5 rounded-full bg-orange-100 text-orange-700">Mañana</span>;
  if (days <= 3)  return <span className="text-xs font-semibold px-2 py-0.5 rounded-full bg-amber-100 text-amber-700">{days}d</span>;
  return <span className="text-xs font-semibold px-2 py-0.5 rounded-full bg-gray-100 text-gray-600">{days}d</span>;
}

function Skeleton() {
  return <div className="bg-white rounded-2xl p-4 shadow-sm animate-pulse h-20" />;
}

function SectionHeader({ title, onMore }: { title: string; onMore: () => void }) {
  return (
    <div className="flex items-center justify-between mb-2 px-1">
      <h2 className="text-xs font-bold text-gray-500 uppercase tracking-wider">{title}</h2>
      <button onClick={onMore} className="text-xs text-[#008899] flex items-center gap-0.5 font-medium">
        Ver todo <ChevronRight size={13} />
      </button>
    </div>
  );
}

const quickAccessButtonClass =
  'bg-[#cfeff2] border border-[#8fd3da] rounded-2xl p-4 text-left shadow-sm hover:bg-[#bce7eb] hover:border-[#75c6ce] active:scale-95 transition-all';
const quickAccessIconClass = 'text-[#007a86] mb-2';
const quickAccessTitleClass = 'text-sm font-semibold text-[#005f68]';
const quickAccessSubtitleClass = 'text-xs text-[#31747b]';

export function DashboardScreen() {
  const navigate = useNavigate();
  const [userRole, setUserRole] = useState<string | null>(null);
  const [userName, setUserName] = useState('');
  const [events, setEvents] = useState<CalendarEvent[]>([]);
  const [metrics, setMetrics] = useState<AttendanceMetrics | null>(null);
  const [grades, setGrades] = useState<GradeOut[]>([]);
  const [loading, setLoading] = useState(true);

  const today = getDayKey(new Date());

  const greeting = useMemo(() => {
    const h = new Date().getHours();
    if (h < 13) return 'Buenos días';
    if (h < 20) return 'Buenas tardes';
    return 'Buenas noches';
  }, []);

  const todayLabel = useMemo(
    () => new Intl.DateTimeFormat('es-ES', { weekday: 'long', day: 'numeric', month: 'long' }).format(new Date()),
    [],
  );

  useEffect(() => {
    const role = localStorage.getItem('userRole');
    const name = localStorage.getItem('userName') || '';
    setUserRole(role);
    setUserName(name);

    (async () => {
      try {
        const evs = await getCalendarEvents();
        setEvents(evs);
        if (role === 'student') {
          const [m, g] = await Promise.all([
            getMyAttendanceMetrics().catch(() => null),
            getMyGrades().catch(() => [] as GradeOut[]),
          ]);
          if (m) setMetrics(m);
          setGrades(g);
        }
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  const todayClasses = useMemo(
    () =>
      events
        .filter(e =>
          (e.tipo === 'class' || e.tipo === 'international') &&
          getDayKey(e.fecha_inicio) <= today &&
          getDayKey(e.fecha_fin) >= today,
        )
        .sort((a, b) => a.fecha_inicio.localeCompare(b.fecha_inicio)),
    [events, today],
  );

  const nextClass = useMemo(
    () =>
      events
        .filter(e =>
          (e.tipo === 'class' || e.tipo === 'international') &&
          getDayKey(e.fecha_inicio) > today,
        )
        .sort((a, b) => a.fecha_inicio.localeCompare(b.fecha_inicio))[0] ?? null,
    [events, today],
  );

  const upcomingDeliveries = useMemo(
    () =>
      events
        .filter(e => e.tipo === 'delivery' && getDayKey(e.fecha_inicio) >= today)
        .sort((a, b) => a.fecha_inicio.localeCompare(b.fecha_inicio)),
    [events, today],
  );

  const nextDeliveries = upcomingDeliveries.slice(0, 3);

  const upcomingOther = useMemo(
    () =>
      events
        .filter(e => e.tipo !== 'class' && e.tipo !== 'delivery' && getDayKey(e.fecha_inicio) >= today)
        .sort((a, b) => a.fecha_inicio.localeCompare(b.fecha_inicio))
        .slice(0, 3),
    [events, today],
  );

  const gradeAverage = useMemo(() => {
    const graded = grades.filter(g => g.nota !== null);
    if (!graded.length) return null;
    return (graded.reduce((s, g) => s + (g.nota ?? 0), 0) / graded.length).toFixed(1);
  }, [grades]);

  const firstName = userName.split(' ')[0] || '';

  return (
    <div className="min-h-screen bg-[#f0f2f5] pb-24">
      {/* ── Header ── */}
      <div className="bg-[#008899] px-5 pt-12 pb-6 rounded-b-3xl shadow-md">
        <div className="flex items-start justify-between mb-1">
          <div>
            <p className="text-white/60 text-xs uppercase tracking-widest">EDEM Student Hub</p>
            <h1 className="text-white text-xl font-semibold mt-0.5">
              {greeting}{firstName ? `, ${firstName}` : ''}
            </h1>
            <p className="text-white/70 text-sm capitalize mt-0.5">{todayLabel}</p>
          </div>
          <button
            onClick={() => navigate('/notifications')}
            className="bg-white/20 hover:bg-white/30 transition-colors p-2.5 rounded-full mt-1"
          >
            <Bell size={18} className="text-white" />
          </button>
        </div>

        {/* Stats bubbles – students only */}
        {userRole === 'student' && (
          <div className="flex justify-center gap-6 mt-6">
            <button
              onClick={() => navigate('/attendance')}
              className="flex flex-col items-center justify-center w-28 h-28 rounded-full bg-[#cfeff2] hover:bg-[#bce7eb] active:scale-95 transition-all border-2 border-[#8fd3da] shadow-sm"
            >
              <p className="text-black text-3xl font-bold leading-none">
                {loading ? '—' : metrics ? `${metrics.porcentaje_asistencia.toFixed(0)}%` : '—'}
              </p>
              <p className="text-black text-xs mt-1.5">Asistencia</p>
              <p className="text-black text-[10px] mt-0.5">
                {!loading && metrics ? `${metrics.clases_asistidas}/${metrics.total_clases}` : ''}
              </p>
            </button>
            <button
              onClick={() => navigate('/grades')}
              className="flex flex-col items-center justify-center w-28 h-28 rounded-full bg-[#cfeff2] hover:bg-[#bce7eb] active:scale-95 transition-all border-2 border-[#8fd3da] shadow-sm"
            >
              <p className="text-black text-3xl font-bold leading-none">
                {loading ? '—' : gradeAverage ?? '—'}
              </p>
              <p className="text-black text-xs mt-1.5">Nota media</p>
              <p className="text-black text-[10px] mt-0.5">
                {!loading ? `${grades.filter(g => g.nota !== null).length} evaluadas` : ''}
              </p>
            </button>
          </div>
        )}
      </div>

      <div className="px-4 mt-5 space-y-5">
        {/* ── Clase de hoy ── */}
        <section>
          <SectionHeader
            title={todayClasses.length > 0 ? 'Clase de hoy' : 'Próxima clase'}
            onMore={() => navigate('/calendar')}
          />
          {loading ? (
            <Skeleton />
          ) : todayClasses.length === 0 && !nextClass ? (
            <div className="bg-white rounded-2xl p-4 shadow-sm flex items-center gap-3">
              <div className="bg-gray-100 rounded-xl p-2.5">
                <BookOpen size={18} className="text-gray-400" />
              </div>
              <p className="text-sm text-gray-400">Sin clases programadas</p>
            </div>
          ) : todayClasses.length === 0 && nextClass ? (
            <div className="bg-white rounded-2xl p-4 shadow-sm">
              <div className="flex items-start gap-3">
                <div className="bg-blue-100 rounded-xl p-2.5 flex-shrink-0">
                  <BookOpen size={18} className="text-blue-600" />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="font-semibold text-gray-800 text-sm leading-tight">{nextClass.titulo}</p>
                  {nextClass.bloque_nombre && (
                    <p className="text-xs text-gray-400 mt-0.5">{nextClass.bloque_nombre}</p>
                  )}
                  <div className="flex flex-wrap items-center gap-3 mt-2">
                    <span className="flex items-center gap-1 text-xs text-gray-500 capitalize">
                      <CalendarDays size={11} />
                      {formatShortDate(nextClass.fecha_inicio)}
                    </span>
                    <span className="flex items-center gap-1 text-xs text-gray-500">
                      <Clock size={11} />
                      {formatTime(nextClass.fecha_inicio)} – {formatTime(nextClass.fecha_fin)}
                    </span>
                    {nextClass.aula && (
                      <span className="flex items-center gap-1 text-xs text-gray-500">
                        <MapPin size={11} />
                        {nextClass.aula}
                      </span>
                    )}
                  </div>
                  {nextClass.profesor_nombre && (
                    <p className="text-xs text-[#008899] font-medium mt-1">{nextClass.profesor_nombre}</p>
                  )}
                </div>
              </div>
            </div>
          ) : (
            <div className="space-y-2">
              {todayClasses.map(ev => {
                const meta = EVENT_META[ev.tipo] ?? EVENT_META.class;
                const Icon = meta.icon;
                return (
                <div key={ev.id} className="bg-white rounded-2xl p-4 shadow-sm">
                  <div className="flex items-start gap-3">
                    <div className={`${meta.bg} rounded-xl p-2.5 flex-shrink-0`}>
                      <Icon size={18} className={meta.color} />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="font-semibold text-gray-800 text-sm leading-tight">{ev.titulo}</p>
                      {ev.bloque_nombre && (
                        <p className="text-xs text-gray-400 mt-0.5">{ev.bloque_nombre}</p>
                      )}
                      <div className="flex flex-wrap items-center gap-3 mt-2">
                        <span className="flex items-center gap-1 text-xs text-gray-500">
                          <Clock size={11} />
                          {formatTime(ev.fecha_inicio)} – {formatTime(ev.fecha_fin)}
                        </span>
                        {ev.aula && (
                          <span className="flex items-center gap-1 text-xs text-gray-500">
                            <MapPin size={11} />
                            {ev.aula}
                          </span>
                        )}
                      </div>
                      {ev.profesor_nombre && (
                        <p className="text-xs text-[#008899] font-medium mt-1">{ev.profesor_nombre}</p>
                      )}
                    </div>
                  </div>
                </div>
              ); })}
            </div>
          )}
        </section>

        {/* ── Próximas entregas ── */}
        <section>
          <SectionHeader title="Próximas entregas" onMore={() => navigate('/deliveries')} />
          {loading ? (
            <Skeleton />
          ) : nextDeliveries.length === 0 ? (
            <div className="bg-white rounded-2xl p-4 shadow-sm flex items-center gap-3">
              <div className="bg-gray-100 rounded-xl p-2.5">
                <FileText size={18} className="text-gray-400" />
              </div>
              <p className="text-sm text-gray-400">Sin entregas próximas</p>
            </div>
          ) : (
            <div className="space-y-2">
              {nextDeliveries.map(ev => {
                const days = daysFromNow(ev.fecha_inicio);
                const urgent = days <= 1;
                return (
                  <div key={ev.id} className={`rounded-2xl p-4 shadow-sm ${urgent ? 'bg-amber-50 border border-amber-200' : 'bg-white'}`}>
                    <div className="flex items-start gap-3">
                      <div className={`rounded-xl p-2.5 flex-shrink-0 ${urgent ? 'bg-amber-100' : 'bg-amber-50'}`}>
                        <FileText size={18} className="text-amber-600" />
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="font-semibold text-gray-800 text-sm leading-tight">{ev.titulo}</p>
                        {ev.bloque_nombre && (
                          <p className="text-xs text-gray-400 mt-0.5">{ev.bloque_nombre}</p>
                        )}
                        <div className="flex items-center justify-between mt-2">
                          <span className="text-xs text-gray-500 capitalize">{formatShortDate(ev.fecha_inicio)}</span>
                          <DeadlineBadge days={days} />
                        </div>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </section>

        {/* ── Próximos eventos ── */}
        {!loading && upcomingOther.length > 0 && (
          <section>
            <SectionHeader title="Próximos eventos" onMore={() => navigate('/calendar')} />
            <div className="space-y-2">
              {upcomingOther.map(ev => {
                const meta = EVENT_META[ev.tipo] ?? { label: ev.tipo, icon: CalendarDays, color: 'text-gray-600', bg: 'bg-gray-100' };
                const Icon = meta.icon;
                return (
                  <div key={ev.id} className="bg-white rounded-2xl p-4 shadow-sm flex items-center gap-3">
                    <div className={`rounded-xl p-2.5 flex-shrink-0 ${meta.bg}`}>
                      <Icon size={18} className={meta.color} />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-0.5">
                        <span className={`text-[10px] font-semibold px-1.5 py-0.5 rounded uppercase tracking-wide ${meta.bg} ${meta.color}`}>
                          {meta.label}
                        </span>
                      </div>
                      <p className="font-semibold text-gray-800 text-sm truncate">{ev.titulo}</p>
                      <p className="text-xs text-gray-400 capitalize mt-0.5">{formatShortDate(ev.fecha_inicio)}</p>
                    </div>
                    <DeadlineBadge days={daysFromNow(ev.fecha_inicio)} />
                  </div>
                );
              })}
            </div>
          </section>
        )}

        {/* ── Accesos rápidos ── */}
        <section>
          <h2 className="text-xs font-bold text-gray-500 uppercase tracking-wider mb-2 px-1">Accesos rápidos</h2>
          <div className="grid grid-cols-2 gap-3">
            <button
              onClick={() => window.open('https://empleo.marinadeempresas.es/portal', '_blank')}
              className={quickAccessButtonClass}
            >
              <BriefcaseBusiness size={22} className={quickAccessIconClass} />
              <p className={quickAccessTitleClass}>Empleabilidad</p>
              <p className={quickAccessSubtitleClass}>Portal Marina de Empresas</p>
            </button>

            <button
              onClick={() => navigate('/rooms')}
              className={quickAccessButtonClass}
            >
              <MapPin size={22} className={quickAccessIconClass} />
              <p className={quickAccessTitleClass}>Salas</p>
              <p className={quickAccessSubtitleClass}>Reservar espacio</p>
            </button>

            {userRole === 'student' && (
              <>
                <button
                  onClick={() => navigate('/grades')}
                  className={quickAccessButtonClass}
                >
                  <TrendingUp size={22} className={quickAccessIconClass} />
                  <p className={quickAccessTitleClass}>Mis notas</p>
                  <p className={quickAccessSubtitleClass}>Media: {gradeAverage ?? '—'}</p>
                </button>
                <button
                  onClick={() => navigate('/deliveries')}
                  className={quickAccessButtonClass}
                >
                  <FileText size={22} className={quickAccessIconClass} />
                  <p className={quickAccessTitleClass}>Entregas</p>
                  <p className={quickAccessSubtitleClass}>
                    {loading ? 'Cargando...' : `${upcomingDeliveries.length} restantes`}
                  </p>
                </button>
              </>
            )}

            {userRole !== 'student' && (
              <button
                onClick={() => navigate('/deliveries')}
                className={quickAccessButtonClass}
              >
                <FileText size={22} className={quickAccessIconClass} />
                <p className={quickAccessTitleClass}>Entregas</p>
                <p className={quickAccessSubtitleClass}>
                  {loading ? 'Cargando...' : `${upcomingDeliveries.length} restantes`}
                </p>
              </button>
            )}
          </div>
        </section>
      </div>
    </div>
  );
}
