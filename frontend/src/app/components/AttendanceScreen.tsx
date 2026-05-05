import { useEffect, useState } from 'react';
import { CheckCircle, ChevronLeft, Clock, Users, XCircle } from 'lucide-react';
import { useNavigate } from 'react-router';
import {
  checkInAttendance,
  getCalendarEvents,
  getMyAttendance,
  getMyAttendanceMetrics,
  type AttendanceMetrics,
  type AttendanceRecord,
  type CalendarEvent,
} from '../api/client';

interface SessionAttendance {
  id_sesion: string;
  title: string;
  dateLabel: string;
  shortDateLabel: string;
  attended: boolean;
  sessionNumber: number;
  totalSessions: number;
  cumulativePct: number;
}

const sameDay = (a: Date, b: Date) =>
  a.getFullYear() === b.getFullYear() &&
  a.getMonth() === b.getMonth() &&
  a.getDate() === b.getDate();

const formatSessionDate = (value: string) =>
  new Intl.DateTimeFormat('es-ES', {
    weekday: 'short',
    day: '2-digit',
    month: 'short',
    hour: '2-digit',
    minute: '2-digit',
  }).format(new Date(value));

const formatShortSessionDate = (value: string) =>
  new Intl.DateTimeFormat('es-ES', {
    day: '2-digit',
    month: 'short',
  }).format(new Date(value));

const normalizeText = (value: string | null | undefined) =>
  (value ?? '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase();

const isMandatoryAttendanceEvent = (event: CalendarEvent) => {
  const title = normalizeText(event.titulo);
  return !['tfm', 'visita', 'empleabilidad', 'experiencia internacional', 'foto orla'].some((fragment) =>
    title.includes(fragment),
  );
};

const getSessionTitle = (event: CalendarEvent) =>
  event.titulo.replace(/^SES-\d+\s*[-:|]?\s*/i, '').trim() || event.titulo;

function RingChart({ pct, size = 56 }: { pct: number; size?: number }) {
  const safePct = Math.max(0, Math.min(100, pct));
  const r = (size - 8) / 2;
  const circ = 2 * Math.PI * r;
  const dash = (safePct / 100) * circ;
  const gap = circ - dash;
  const color = safePct >= 90 ? '#22c55e' : safePct >= 80 ? '#3b82f6' : safePct >= 50 ? '#f59e0b' : '#ef4444';

  return (
    <svg width={size} height={size} className="-rotate-90" style={{ display: 'block' }}>
      <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke="#e5e7eb" strokeWidth={6} />
      <circle
        cx={size / 2}
        cy={size / 2}
        r={r}
        fill="none"
        stroke={color}
        strokeWidth={6}
        strokeDasharray={`${dash} ${gap}`}
        strokeLinecap="round"
      />
    </svg>
  );
}

export function AttendanceScreen() {
  const navigate = useNavigate();
  const [records, setRecords] = useState<AttendanceRecord[]>([]);
  const [classEvents, setClassEvents] = useState<CalendarEvent[]>([]);
  const [mandatoryEvents, setMandatoryEvents] = useState<CalendarEvent[]>([]);
  const [metrics, setMetrics] = useState<AttendanceMetrics | null>(null);
  const [loading, setLoading] = useState(true);
  const [checkInMessage, setCheckInMessage] = useState<string | null>(null);
  const [userRole, setUserRole] = useState<string | null>(null);

  useEffect(() => {
    const storedRole = localStorage.getItem('userRole');
    setUserRole(storedRole);

    getMyAttendance()
      .then(setRecords)
      .catch(() => setRecords([]))
      .finally(() => setLoading(false));

    if (storedRole === 'student') {
      getMyAttendanceMetrics()
        .then(setMetrics)
        .catch(() => setMetrics(null));
    }

    getCalendarEvents()
      .then((events) => {
        const now = Date.now();
        const mandatory = events
          .filter((event) => event.tipo === 'class' && Boolean(event.id_sesion))
          .filter(isMandatoryAttendanceEvent)
          .sort((a, b) => new Date(a.fecha_inicio).getTime() - new Date(b.fecha_inicio).getTime());

        setMandatoryEvents(mandatory);
        setClassEvents(
          mandatory
            .filter((event) => new Date(event.fecha_fin).getTime() >= now - 1000 * 60 * 60 * 6)
            .sort((a, b) => Math.abs(new Date(a.fecha_inicio).getTime() - now) - Math.abs(new Date(b.fecha_inicio).getTime() - now))
            .slice(0, 8),
        );
      })
      .catch(() => {
        setMandatoryEvents([]);
        setClassEvents([]);
      });
  }, []);

  const reloadAttendance = async () => {
    setRecords(await getMyAttendance());
    if (userRole === 'student') {
      setMetrics(await getMyAttendanceMetrics());
    }
  };

  const handleCheckIn = async (sessionId: string) => {
    setCheckInMessage(null);
    try {
      await checkInAttendance(sessionId);
      await reloadAttendance();
      setCheckInMessage('Asistencia registrada');
    } catch (error) {
      setCheckInMessage(error instanceof Error ? error.message : 'No se ha podido registrar la asistencia');
    }
  };

  const recordBySession = new Map(records.map((record) => [record.id_sesion, record]));
  const now = Date.now();
  const pastMandatoryEvents = mandatoryEvents.filter((event) => new Date(event.fecha_inicio).getTime() <= now);
  const totalMandatorySessions = metrics?.total_clases ?? pastMandatoryEvents.length;
  let attendedUntilSession = 0;
  const sessionRows: SessionAttendance[] = pastMandatoryEvents.map((event, index) => {
    const attended = recordBySession.get(event.id_sesion ?? '')?.presente === true;
    if (attended) attendedUntilSession += 1;

    return {
      id_sesion: event.id_sesion ?? event.id,
      title: getSessionTitle(event),
      dateLabel: formatSessionDate(event.fecha_inicio),
      shortDateLabel: formatShortSessionDate(event.fecha_inicio),
      attended,
      sessionNumber: index + 1,
      totalSessions: totalMandatorySessions,
      cumulativePct: Math.round((attendedUntilSession / (index + 1)) * 100),
    };
  });

  const overallAttended = metrics?.clases_asistidas ?? records.filter((record) => record.presente).length;
  const overallTotal = metrics?.total_clases ?? totalMandatorySessions;
  const overallPct = metrics ? Math.round(metrics.porcentaje_asistencia) : overallTotal > 0 ? Math.round((overallAttended / overallTotal) * 100) : 0;
  const attendedSessionIds = new Set(records.filter((record) => record.presente).map((record) => record.id_sesion));
  const todaySessions = classEvents.filter((event) => sameDay(new Date(event.fecha_inicio), new Date()));
  const suggestedSessions = todaySessions.length > 0 ? todaySessions : classEvents.slice(0, 3);
  const isProfessor = userRole === 'professor';

  return (
    <div className="min-h-screen bg-[#008899] pb-20">
      <div className="px-5 pt-12 pb-6">
        <div className="flex items-center gap-3 mb-6">
          <button onClick={() => navigate(-1)} className="p-1">
            <ChevronLeft className="text-white" size={24} />
          </button>
          <div>
            <h1 className="text-white text-xl" style={{ fontWeight: 300, fontFamily: 'Didot, Bodoni, serif' }}>EDEM</h1>
            <p className="text-white text-xs opacity-80">EDEM STUDENT HUB</p>
          </div>
        </div>

        {!isProfessor && (
          <>
            <div className="bg-white/15 rounded-2xl p-4 flex items-center gap-4">
              <div className="relative flex-shrink-0">
                <RingChart pct={overallPct} size={64} />
                <div className="absolute inset-0 flex items-center justify-center">
                  <span className="text-white text-xs" style={{ fontWeight: 800 }}>{overallPct}%</span>
                </div>
              </div>
              <div className="flex-1">
                <p className="text-white/70 text-xs mb-0.5">Asistencia Global</p>
                <p className="text-white text-base" style={{ fontWeight: 700 }}>
                  {overallAttended}/{overallTotal} clases
                </p>
                <p className="text-white/60 text-xs">Curso 2025-26</p>
                {metrics && (
                  <p className="text-white/60 text-xs">
                    Puedes faltar {metrics.faltas_restantes_80} de {metrics.faltas_permitidas_80} antes del 80%
                  </p>
                )}
              </div>
            </div>
            {metrics?.aviso && (
              <div className="mt-3 rounded-2xl bg-red-500/20 border border-red-200/40 px-4 py-3">
                <p className="text-white text-sm" style={{ fontWeight: 700 }}>Aviso de asistencia</p>
                <p className="text-white/80 text-xs mt-0.5">{metrics.aviso}</p>
              </div>
            )}

            <div className="grid grid-cols-3 gap-2 mt-3">
              {[
                { icon: CheckCircle, label: 'Asistidas', value: overallAttended, color: 'text-green-300' },
                { icon: XCircle, label: 'Faltas', value: overallTotal - overallAttended, color: 'text-red-300' },
                { icon: Clock, label: 'Sesiones', value: overallTotal, color: 'text-amber-300' },
              ].map(({ icon: Icon, label, value, color }) => (
                <div key={label} className="bg-white/10 rounded-xl py-2 px-3 text-center">
                  <Icon size={16} className={`mx-auto mb-0.5 ${color}`} />
                  <p className="text-white text-sm" style={{ fontWeight: 700 }}>{value}</p>
                  <p className="text-white/60 text-xs">{label}</p>
                </div>
              ))}
            </div>
          </>
        )}
      </div>

      <div className="bg-white rounded-t-3xl px-5 pt-5 pb-6 min-h-[60vh]">
        <div className="mb-6">
          <div className="flex items-center gap-2 mb-3">
            <CheckCircle size={18} className="text-[#008899]" />
            <h2 className="text-[#008899]" style={{ fontWeight: 700 }}>REGISTRAR ASISTENCIA</h2>
          </div>
          {suggestedSessions.length === 0 ? (
            <p className="text-gray-400 text-sm">No hay sesiones disponibles para registrar.</p>
          ) : (
            <div className="space-y-2">
              {suggestedSessions.map((event) => {
                const alreadyCheckedIn = event.id_sesion ? attendedSessionIds.has(event.id_sesion) : false;
                return (
                  <div key={event.id} className="bg-gray-50 rounded-2xl p-3 flex items-center justify-between gap-3">
                    <div className="min-w-0">
                      <p className="text-gray-800 text-sm truncate" style={{ fontWeight: 600 }}>{getSessionTitle(event)}</p>
                      <p className="text-xs text-gray-400">{formatSessionDate(event.fecha_inicio)} · {event.aula ?? event.id_sesion}</p>
                    </div>
                    <button
                      onClick={() => event.id_sesion && handleCheckIn(event.id_sesion)}
                      disabled={alreadyCheckedIn}
                      className="bg-[#008899] disabled:bg-green-100 disabled:text-green-700 text-white text-xs px-3 py-2 rounded-lg hover:bg-[#007788] transition-colors"
                    >
                      {alreadyCheckedIn ? 'Registrada' : 'Estoy aqui'}
                    </button>
                  </div>
                );
              })}
            </div>
          )}
          {checkInMessage && <p className="mt-3 text-center text-sm text-gray-500">{checkInMessage}</p>}
        </div>

        {!isProfessor && (
          <>
            <div className="flex items-center gap-2 mb-5">
              <Users size={18} className="text-[#008899]" />
              <h2 className="text-[#008899]" style={{ fontWeight: 700 }}>ASISTENCIA POR SESION</h2>
            </div>

            {loading ? (
              <p className="text-gray-400 text-sm text-center py-8">Cargando asistencia...</p>
            ) : sessionRows.length === 0 ? (
              <p className="text-gray-400 text-sm text-center py-8">No hay registros de asistencia.</p>
            ) : (
              <div className="space-y-3">
                {sessionRows.map((row) => (
                  <div key={row.id_sesion} className="bg-gray-50 rounded-2xl p-4">
                    <div className="flex items-center gap-3 mb-2">
                      <div className="relative flex-shrink-0">
                        <RingChart pct={row.cumulativePct} size={44} />
                        <div className="absolute inset-0 flex items-center justify-center">
                          <span className="text-gray-700 text-xs" style={{ fontWeight: 700 }}>{row.cumulativePct}%</span>
                        </div>
                      </div>

                      <div className="flex-1 min-w-0">
                        <p className="text-gray-800 text-sm truncate" style={{ fontWeight: 600 }}>
                          {row.title}
                        </p>
                        <p className="text-xs text-gray-400">{row.dateLabel}</p>
                      </div>

                      <span
                        className="text-xs px-2 py-0.5 rounded-full flex-shrink-0 bg-white text-gray-500"
                        style={{ fontWeight: 600 }}
                      >
                        {row.shortDateLabel}
                      </span>
                    </div>

                    <div className="flex justify-between mt-1">
                      <span className="text-xs text-gray-400">
                        {row.sessionNumber}/{row.totalSessions} clases
                      </span>
                      <span className={`text-xs ${row.attended ? 'text-green-500' : 'text-red-400'}`}>
                        {row.attended ? 'Asistida' : 'Falta'}
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
}
