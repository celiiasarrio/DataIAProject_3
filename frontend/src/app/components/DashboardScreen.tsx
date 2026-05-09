import { BookOpen, CheckCircle, Calendar, Users, Clock, MessageSquare } from 'lucide-react';
import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router';
import {
  getDashboard,
  type GradeOut,
  type AttendanceMetrics,
  type CalendarEvent,
} from '../api/client';
import { CenteredLoadingSpinner } from './ui/LoadingSpinner';

const EVENT_TYPE_CONFIG: Record<string, { label: string; bgColor: string; chipColor: string }> = {
  class: { label: 'Sesión', bgColor: 'bg-blue-50', chipColor: 'bg-blue-500' },
  delivery: { label: 'Entrega', bgColor: 'bg-amber-50', chipColor: 'bg-amber-400' },
  international: { label: 'Experiencia intl.', bgColor: 'bg-lime-50', chipColor: 'bg-lime-500' },
  softSkills: { label: 'Soft Skills', bgColor: 'bg-rose-50', chipColor: 'bg-rose-500' },
  tfm: { label: 'TFM', bgColor: 'bg-violet-50', chipColor: 'bg-violet-500' },
  hackathon: { label: 'Hackatón', bgColor: 'bg-red-50', chipColor: 'bg-red-500' },
  visit: { label: 'Visita', bgColor: 'bg-sky-50', chipColor: 'bg-sky-500' },
  employability: { label: 'Empleabilidad', bgColor: 'bg-teal-50', chipColor: 'bg-teal-500' },
};

const getDayKey = (d: Date | string): string => {
  const date = typeof d === 'string' ? new Date(d) : d;
  return date.toISOString().slice(0, 10);
};

const formatEventTime = (dateStr: string): string => {
  return new Intl.DateTimeFormat('es-ES', { hour: '2-digit', minute: '2-digit' }).format(new Date(dateStr));
};

const formatEventDate = (dateStr: string): string => {
  return new Intl.DateTimeFormat('es-ES', { day: '2-digit', month: 'short' }).format(new Date(dateStr));
};

const formatEventLocation = (event: CalendarEvent): string | null => {
  const planta =
    event.planta?.toLowerCase() === 'baja'
      ? 'Planta baja'
      : event.planta
        ? `Planta ${event.planta}`
        : null;
  return [event.aula, event.edificio, planta].filter(Boolean).join(' · ') || null;
};

export function DashboardScreen() {
  const navigate = useNavigate();
  const [grades, setGrades] = useState<GradeOut[]>([]);
  const [attendance, setAttendance] = useState<AttendanceMetrics | null>(null);
  const [events, setEvents] = useState<CalendarEvent[]>([]);
  const [loading, setLoading] = useState(true);
  const [userName, setUserName] = useState<string>('');

  useEffect(() => {
    setUserName(localStorage.getItem('userName') || '');

    getDashboard()
      .then((data) => {
        setGrades(data.grades);
        setAttendance(data.attendance);
        setEvents(data.events);
      })
      .finally(() => setLoading(false));
  }, []);

  const userRole = localStorage.getItem('userRole') || 'student';

  const calculateGradeAverage = (): number | null => {
    if (!grades || grades.length === 0) return null;

    const categories = {
      entregables: { weight: 20, grades: [] as number[] },
      data_projects: { weight: 30, grades: [] as number[] },
      actitud: { weight: 10, grades: [] as number[] },
      tfm: { weight: 40, grades: [] as number[] },
    };

    grades.forEach(g => {
      if (g.nota !== null && g.nota !== undefined && categories[g.categoria as keyof typeof categories]) {
        categories[g.categoria as keyof typeof categories].grades.push(g.nota);
      }
    });

    let totalWeighted = 0;
    let totalWeight = 0;

    Object.entries(categories).forEach(([_, cat]) => {
      if (cat.grades.length > 0) {
        const avg = cat.grades.reduce((a, b) => a + b, 0) / cat.grades.length;
        totalWeighted += avg * cat.weight;
        totalWeight += cat.weight;
      }
    });

    return totalWeight > 0 ? totalWeighted / totalWeight : null;
  };

  const todayKey = getDayKey(new Date());
  const getTodayEvents = (): CalendarEvent[] => {
    if (!events) return [];
    return events
      .filter(ev => {
        const start = getDayKey(ev.fecha_inicio);
        const end = getDayKey(ev.fecha_fin);
        return start <= todayKey && todayKey <= end;
      })
      .slice(0, 5);
  };

  const getUpcomingDeliveries = (): CalendarEvent[] => {
    if (!events) return [];
    const now = new Date();
    const in14Days = new Date(now.getTime() + 14 * 24 * 60 * 60 * 1000);
    return events
      .filter(ev => ev.tipo === 'delivery' && new Date(ev.fecha_inicio) > now && new Date(ev.fecha_inicio) < in14Days)
      .sort((a, b) => new Date(a.fecha_inicio).getTime() - new Date(b.fecha_inicio).getTime())
      .slice(0, 5);
  };

  const getUpcomingClasses = (): CalendarEvent[] => {
    if (!events) return [];
    const now = new Date();
    return events
      .filter((ev) => ev.tipo === 'class' && new Date(ev.fecha_fin) >= now)
      .sort((a, b) => new Date(a.fecha_inicio).getTime() - new Date(b.fecha_inicio).getTime())
      .slice(0, 6);
  };

  const avgGrade = calculateGradeAverage();

  const coordinatorActions = [
    {
      icon: BookOpen,
      title: 'Notas alumnos',
      description: 'Edita calificaciones por asignatura y tarea.',
      action: 'Gestionar notas',
      route: '/teacher/grades',
    },
    {
      icon: CheckCircle,
      title: 'Asistencia',
      description: 'Marca o quita asistencia de los alumnos.',
      action: 'Gestionar asistencia',
      route: '/group-attendance',
    },
    {
      icon: MessageSquare,
      title: 'Tutorias',
      description: 'Revisa y responde solicitudes de tutoria.',
      action: 'Ver tutorias',
      route: '/tutoring',
    },
  ];

  const professorActions = [
    {
      icon: BookOpen,
      title: 'Notas alumnos',
      description: 'Introduce y edita calificaciones de tus asignaturas.',
      action: 'Gestionar notas',
      route: '/teacher/grades',
    },
    {
      icon: CheckCircle,
      title: 'Mi asistencia',
      description: 'Marca tu asistencia a las sesiones que impartes.',
      action: 'Registrar asistencia',
      route: '/attendance',
    },
    {
      icon: MessageSquare,
      title: 'Tutorias',
      description: 'Revisa solicitudes y responde a tus alumnos.',
      action: 'Gestionar tutorias',
      route: '/tutoring',
    },
  ];

  if (userRole !== 'student' && userRole !== 'professor') {
    return (
      <div className="min-h-screen bg-[#f5f5f5] dark:bg-gray-950 pb-24">
        <div className="bg-[#008899] px-6 pt-12 pb-16 rounded-b-3xl">
          <div className="flex items-center justify-between mb-5">
            <div>
              <h1 className="text-white text-2xl mb-1" style={{ fontWeight: 300, fontFamily: 'Didot, Bodoni, serif' }}>EDEM</h1>
              <p className="text-white text-xs opacity-90">Panel de coordinación</p>
            </div>
          </div>
          <p className="text-white text-lg">Hola{userName ? `, ${userName.split(' ')[0]}` : ''}</p>
        </div>

        <div className="px-6 -mt-10">
          <div className="bg-white dark:bg-gray-900 rounded-2xl p-5 shadow-sm">
            <div className="text-center mb-5">
              <h2 className="text-[#008899] text-lg" style={{ fontWeight: 800 }}>Gestión académica</h2>
              <p className="text-gray-500 text-sm mt-1">Accesos principales de coordinación</p>
            </div>
            <div className="grid gap-3 sm:grid-cols-3 justify-items-center">
              {coordinatorActions.map(({ icon: Icon, title, description, action, route }) => (
                <div key={title} className="bg-gray-50 dark:bg-gray-800 rounded-2xl p-4 flex flex-col items-center text-center w-full max-w-xs">
                  <div className="h-11 w-11 rounded-2xl bg-[#008899]/10 flex items-center justify-center mb-3">
                    <Icon size={22} className="text-[#008899]" />
                  </div>
                  <h3 className="text-gray-900 dark:text-gray-100 text-sm" style={{ fontWeight: 800 }}>{title}</h3>
                  <p className="text-gray-500 dark:text-gray-400 text-xs mt-2 flex-1">{description}</p>
                  <button
                    onClick={() => navigate(route)}
                    className="mt-4 w-full bg-[#008899] text-white py-2.5 rounded-xl text-sm hover:bg-[#007788] transition-colors"
                    style={{ fontWeight: 700 }}
                  >
                    {action}
                  </button>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    );
  }

  if (userRole === 'professor') {
    return (
      <div className="min-h-screen bg-[#f5f5f5] pb-24">
        <div className="bg-[#008899] px-6 pt-12 pb-16 rounded-b-3xl">
          <div className="flex items-center justify-between mb-5">
            <div>
              <h1 className="text-white text-2xl mb-1" style={{ fontWeight: 300, fontFamily: 'Didot, Bodoni, serif' }}>EDEM</h1>
              <p className="text-white text-xs opacity-90">Panel de profesor</p>
            </div>
          </div>
          <p className="text-white text-lg">Hola{userName ? `, ${userName.split(' ')[0]}` : ''}</p>
        </div>

        <div className="px-6 -mt-10">
          <div className="bg-white rounded-2xl p-5 shadow-sm">
            <div className="text-center mb-5">
              <h2 className="text-[#008899] text-lg" style={{ fontWeight: 800 }}>Gestion docente</h2>
              <p className="text-gray-500 text-sm mt-1">Accesos principales de profesor</p>
            </div>
            <div className="grid gap-3 sm:grid-cols-3">
              {professorActions.map(({ icon: Icon, title, description, action, route }) => (
                <div key={title} className="bg-gray-50 rounded-2xl p-4 flex flex-col items-center text-center">
                  <div className="h-11 w-11 rounded-2xl bg-[#008899]/10 flex items-center justify-center mb-3">
                    <Icon size={22} className="text-[#008899]" />
                  </div>
                  <h3 className="text-gray-900 text-sm" style={{ fontWeight: 800 }}>{title}</h3>
                  <p className="text-gray-500 text-xs mt-2 flex-1">{description}</p>
                  <button
                    onClick={() => navigate(route)}
                    className="mt-4 w-full bg-[#008899] text-white py-2.5 rounded-xl text-sm hover:bg-[#007788] transition-colors"
                    style={{ fontWeight: 700 }}
                  >
                    {action}
                  </button>
                </div>
              ))}
            </div>
          </div>

          <div className="mt-4 bg-white rounded-2xl p-5 shadow-sm">
            <div className="flex items-center gap-2 mb-4">
              <Calendar size={18} className="text-[#008899]" />
              <h2 className="text-[#008899] text-base" style={{ fontWeight: 800 }}>Mis clases</h2>
            </div>
            {loading ? (
              <CenteredLoadingSpinner className="py-5" />
            ) : getUpcomingClasses().length === 0 ? (
              <p className="text-gray-400 text-sm text-center py-5">No tienes clases próximas.</p>
            ) : (
              <div className="space-y-3">
                {getUpcomingClasses().map((ev) => (
                  <div key={ev.id} className="bg-gray-50 rounded-2xl p-4 border border-gray-100">
                    <div className="flex items-start justify-between gap-3">
                      <div className="min-w-0">
                        <p className="text-gray-900 text-sm truncate" style={{ fontWeight: 800 }}>
                          {ev.titulo}
                        </p>
                        <p className="text-xs text-gray-500 mt-1">
                          {formatEventDate(ev.fecha_inicio)} · {formatEventTime(ev.fecha_inicio)} - {formatEventTime(ev.fecha_fin)}
                        </p>
                        {formatEventLocation(ev) && (
                          <p className="text-xs text-gray-400 mt-1">{formatEventLocation(ev)}</p>
                        )}
                      </div>
                      {ev.bloque_nombre && (
                        <span className="text-xs px-2 py-1 rounded-full bg-white text-[#008899] flex-shrink-0" style={{ fontWeight: 700 }}>
                          {ev.bloque_nombre}
                        </span>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#f5f5f5] dark:bg-gray-950 pb-20">
      {/* Header */}
      <div className="bg-[#008899] px-6 pt-12 pb-6 rounded-b-3xl">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h1 className="text-white text-2xl mb-1" style={{ fontWeight: 300, fontFamily: 'Didot, Bodoni, serif' }}>EDEM</h1>
            <p className="text-white text-xs opacity-90">EDEM STUDENT HUB</p>
          </div>
        </div>
        <p className="text-white text-lg mb-2">Hola{userName ? `, ${userName.split(' ')[0]}` : ''}</p>
      </div>

      {/* Content */}
      <div className="px-6 -mt-4">
        {/* Quick Access */}
        <div className="bg-white dark:bg-gray-900 rounded-xl p-4 mb-4 shadow-sm">
          <div className="flex gap-3 justify-center flex-wrap">
            {userRole === 'student' && [
              { icon: BookOpen, label: 'Notas', route: '/grades' },
              { icon: CheckCircle, label: 'Asistencia', route: '/attendance' },
              { icon: Users, label: 'Tutorías', route: '/tutoring' },
            ].map((item) => (
              <button
                key={item.label}
                onClick={() => item.route && navigate(item.route)}
                className="flex flex-col items-center gap-1 min-w-[60px] p-2 rounded-lg hover:bg-[#f5f5f5] dark:hover:bg-gray-800 transition-colors"
              >
                <item.icon size={20} className="text-[#008899] dark:text-cyan-300" />
                <span className="text-xs text-gray-700 dark:text-gray-300 text-center">{item.label}</span>
              </button>
            ))}
          </div>
        </div>

        {/* Today Card */}
        <div className="bg-white dark:bg-gray-900 rounded-xl p-4 mb-4 shadow-sm">
          <h3 className="text-[#008899] dark:text-cyan-300 mb-3" style={{ fontWeight: 600 }}>HOY</h3>
          {loading ? (
            <CenteredLoadingSpinner className="py-5" />
          ) : getTodayEvents().length > 0 ? (
            <div className="space-y-3">
              {getTodayEvents().map((ev) => (
                <div key={ev.id} className="border-l-4 border-[#008899] pl-3 pb-2">
                  <div className="flex items-start justify-between gap-2 mb-1">
                    <span className="text-sm font-medium text-gray-800 dark:text-gray-100 flex-1">{ev.titulo}</span>
                    <span className={`text-xs px-2 py-1 rounded text-white ${EVENT_TYPE_CONFIG[ev.tipo]?.chipColor || 'bg-gray-400'}`}>
                      {EVENT_TYPE_CONFIG[ev.tipo]?.label || ev.tipo}
                    </span>
                  </div>
                  <div className="flex items-center gap-4 text-xs text-gray-500 dark:text-gray-400">
                    <span className="flex items-center gap-1">
                      <Clock size={14} /> {formatEventTime(ev.fecha_inicio)}
                    </span>
                    {formatEventLocation(ev) && <span>{formatEventLocation(ev)}</span>}
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-sm text-gray-500 dark:text-gray-400">Hoy no tienes clases ni eventos programados.</p>
          )}
        </div>

        {/* Grades & Attendance Indicators (Students only) */}
        {userRole === 'student' && (
          <div className="flex justify-center mb-6">
            <div className="grid grid-cols-2 gap-8">
              {/* Notas Indicator */}
              <button
                onClick={() => navigate('/grades')}
                className="flex flex-col items-center gap-2 focus:outline-none"
              >
                <div className="w-20 h-20 rounded-full bg-white dark:bg-gray-900 shadow-sm flex items-center justify-center cursor-pointer hover:shadow-md transition-shadow border border-gray-200 dark:border-gray-700">
                  {loading ? (
                    <div className="text-xs text-gray-400">...</div>
                  ) : avgGrade !== null ? (
                    <span className="text-2xl" style={{ fontWeight: 800, color: '#008899' }}>
                      {avgGrade.toFixed(1).replace('.', ',')}
                    </span>
                  ) : (
                    <span className="text-xs text-gray-400" style={{ textAlign: 'center' }}>—</span>
                  )}
                </div>
                <span className="text-xs text-gray-600 dark:text-gray-300" style={{ fontWeight: 600 }}>Mis notas</span>
              </button>

              {/* Asistencia Indicator */}
              <button
                onClick={() => navigate('/attendance')}
                className="flex flex-col items-center gap-2 focus:outline-none"
              >
                <div className="w-20 h-20 rounded-full bg-white dark:bg-gray-900 shadow-sm flex items-center justify-center cursor-pointer hover:shadow-md transition-shadow border border-gray-200 dark:border-gray-700">
                  {loading ? (
                    <div className="text-xs text-gray-400">...</div>
                  ) : attendance ? (
                    <span className="text-2xl" style={{ fontWeight: 800, color: '#008899' }}>
                      {attendance.porcentaje_asistencia.toFixed(0)}%
                    </span>
                  ) : (
                    <span className="text-xs text-gray-400" style={{ textAlign: 'center' }}>—</span>
                  )}
                </div>
                <span className="text-xs text-gray-600 dark:text-gray-300" style={{ fontWeight: 600 }}>Asistencia</span>
              </button>
            </div>
          </div>
        )}

        {/* Upcoming Deliveries (Students only) */}
        {userRole === 'student' && (
          <div className="bg-white dark:bg-gray-900 rounded-xl p-4 mb-4 shadow-sm">
            <h3 className="text-[#008899] dark:text-cyan-300 mb-3" style={{ fontWeight: 600 }}>PRÓXIMAS ENTREGAS</h3>
            {loading ? (
              <CenteredLoadingSpinner className="py-5" />
            ) : getUpcomingDeliveries().length > 0 ? (
              <div className="space-y-2">
                {getUpcomingDeliveries().map((ev) => (
                  <div key={ev.id} className="flex items-start justify-between p-2 rounded-lg bg-gray-50 dark:bg-gray-800 border border-gray-100 dark:border-gray-700">
                    <div className="flex-1">
                      <p className="text-sm font-medium text-gray-800 dark:text-gray-100">{ev.titulo}</p>
                      <p className="text-xs text-gray-500 dark:text-gray-400">{formatEventDate(ev.fecha_inicio)}</p>
                    </div>
                    <span className="text-xs px-2 py-1 rounded text-white bg-amber-400">Entrega</span>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-sm text-gray-500 dark:text-gray-400">No tienes entregas próximas.</p>
            )}
          </div>
        )}


      </div>
    </div>
  );
}
