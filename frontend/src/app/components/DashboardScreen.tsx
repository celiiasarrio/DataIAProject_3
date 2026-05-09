import { Bell, BookOpen, CheckCircle, Calendar, DoorOpen, Users, Clock, FileText, Trophy, FolderOpen } from 'lucide-react';
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

  const avgGrade = calculateGradeAverage();

  return (
    <div className="min-h-screen bg-[#f5f5f5] pb-20">
      {/* Header */}
      <div className="bg-[#008899] px-6 pt-12 pb-6 rounded-b-3xl">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h1 className="text-white text-2xl mb-1" style={{ fontWeight: 300, fontFamily: 'Didot, Bodoni, serif' }}>EDEM</h1>
            <p className="text-white text-xs opacity-90">EDEM STUDENT HUB</p>
          </div>
          <Bell className="text-white cursor-pointer" size={24} onClick={() => navigate('/notifications')} />
        </div>
        <p className="text-white text-lg mb-2">Hola{userName ? `, ${userName.split(' ')[0]}` : ''}</p>
      </div>

      {/* Content */}
      <div className="px-6 -mt-4">
        {/* Quick Access */}
        <div className="bg-white rounded-xl p-4 mb-4 shadow-sm overflow-x-auto">
          <div className="flex gap-3 min-w-min">
            {userRole === 'student' && [
              { icon: BookOpen, label: 'Notas', route: '/grades' },
              { icon: CheckCircle, label: 'Asistencia', route: '/attendance' },
              { icon: DoorOpen, label: 'Salas', route: '/rooms' },
              { icon: Users, label: 'Tutorías', route: null },
            ].map((item) => (
              <button
                key={item.label}
                onClick={() => item.route && navigate(item.route)}
                className="flex flex-col items-center gap-1 min-w-[60px] p-2 rounded-lg hover:bg-[#f5f5f5] transition-colors"
              >
                <item.icon size={20} className="text-[#008899]" />
                <span className="text-xs text-gray-700 text-center">{item.label}</span>
              </button>
            ))}
            {userRole === 'professor' && [
              { icon: Calendar, label: 'Mis Clases', route: '/calendar' },
              { icon: BookOpen, label: 'Notas Alumnos', route: '/teacher/grades' },
              { icon: FolderOpen, label: 'Material', route: '/teacher/content' },
              { icon: CheckCircle, label: 'Pase de Lista', route: '/calendar' },
            ].map((item) => (
              <button
                key={item.label}
                onClick={() => item.route && navigate(item.route)}
                className="flex flex-col items-center gap-1 min-w-[60px] p-2 rounded-lg hover:bg-[#f5f5f5] transition-colors"
              >
                <item.icon size={20} className="text-[#008899]" />
                <span className="text-xs text-gray-700 text-center">{item.label}</span>
              </button>
            ))}
            {userRole !== 'student' && userRole !== 'professor' && [
              { icon: Calendar, label: 'Calendario', route: '/calendar' },
              { icon: BookOpen, label: 'Notas Alumnos', route: '/teacher/grades' },
              { icon: CheckCircle, label: 'Asistencia', route: '/calendar' },
            ].map((item) => (
              <button
                key={item.label}
                onClick={() => item.route && navigate(item.route)}
                className="flex flex-col items-center gap-1 min-w-[60px] p-2 rounded-lg hover:bg-[#f5f5f5] transition-colors"
              >
                <item.icon size={20} className="text-[#008899]" />
                <span className="text-xs text-gray-700 text-center">{item.label}</span>
              </button>
            ))}
          </div>
        </div>

        {/* Today Card */}
        <div className="bg-white rounded-xl p-4 mb-4 shadow-sm">
          <h3 className="text-[#008899] mb-3" style={{ fontWeight: 600 }}>HOY</h3>
          {loading ? (
            <CenteredLoadingSpinner className="py-5" />
          ) : getTodayEvents().length > 0 ? (
            <div className="space-y-3">
              {getTodayEvents().map((ev) => (
                <div key={ev.id} className="border-l-4 border-[#008899] pl-3 pb-2">
                  <div className="flex items-start justify-between gap-2 mb-1">
                    <span className="text-sm font-medium text-gray-800 flex-1">{ev.titulo}</span>
                    <span className={`text-xs px-2 py-1 rounded text-white ${EVENT_TYPE_CONFIG[ev.tipo]?.chipColor || 'bg-gray-400'}`}>
                      {EVENT_TYPE_CONFIG[ev.tipo]?.label || ev.tipo}
                    </span>
                  </div>
                  <div className="flex items-center gap-4 text-xs text-gray-500">
                    <span className="flex items-center gap-1">
                      <Clock size={14} /> {formatEventTime(ev.fecha_inicio)}
                    </span>
                    {formatEventLocation(ev) && <span>{formatEventLocation(ev)}</span>}
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-sm text-gray-500">Hoy no tienes clases ni eventos programados.</p>
          )}
        </div>

        {/* Grades & Attendance (Students only) */}
        {userRole === 'student' && (
          <div className="grid grid-cols-2 gap-3 mb-4">
            <div
              className="bg-white rounded-xl p-4 shadow-sm cursor-pointer hover:shadow-md transition-shadow"
              onClick={() => navigate('/grades')}
            >
              <h3 className="text-[#008899] mb-2" style={{ fontWeight: 600 }}>MIS NOTAS</h3>
              {loading ? (
                <CenteredLoadingSpinner className="py-2" size="sm" />
              ) : avgGrade !== null ? (
                <p className="text-2xl" style={{ fontWeight: 800, color: '#008899' }}>{avgGrade.toFixed(1)}</p>
              ) : (
                <p className="text-sm text-gray-500">Todavía no hay calificaciones publicadas.</p>
              )}
              <p className="text-xs text-gray-400 mt-2">Ver calificaciones →</p>
            </div>

            <div
              className="bg-white rounded-xl p-4 shadow-sm cursor-pointer hover:shadow-md transition-shadow"
              onClick={() => navigate('/attendance')}
            >
              <h3 className="text-[#008899] mb-2" style={{ fontWeight: 600 }}>ASISTENCIA</h3>
              {loading ? (
                <CenteredLoadingSpinner className="py-2" size="sm" />
              ) : attendance ? (
                <>
                  <p className="text-2xl" style={{ fontWeight: 800, color: '#008899' }}>{attendance.porcentaje_asistencia.toFixed(0)}%</p>
                  {attendance.aviso && <p className="text-xs text-red-500 mt-2">{attendance.aviso}</p>}
                </>
              ) : (
                <p className="text-sm text-gray-500">Todavía no hay datos de asistencia.</p>
              )}
              <p className="text-xs text-gray-400 mt-2">Ver asistencia →</p>
            </div>
          </div>
        )}

        {/* Upcoming Deliveries (Students only) */}
        {userRole === 'student' && (
          <div className="bg-white rounded-xl p-4 mb-4 shadow-sm">
            <h3 className="text-[#008899] mb-3" style={{ fontWeight: 600 }}>PRÓXIMAS ENTREGAS</h3>
            {loading ? (
              <CenteredLoadingSpinner className="py-5" />
            ) : getUpcomingDeliveries().length > 0 ? (
              <div className="space-y-2">
                {getUpcomingDeliveries().map((ev) => (
                  <div key={ev.id} className="flex items-start justify-between p-2 rounded-lg bg-gray-50 border border-gray-100">
                    <div className="flex-1">
                      <p className="text-sm font-medium text-gray-800">{ev.titulo}</p>
                      <p className="text-xs text-gray-500">{formatEventDate(ev.fecha_inicio)}</p>
                    </div>
                    <span className="text-xs px-2 py-1 rounded text-white bg-amber-400">Entrega</span>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-sm text-gray-500">No tienes entregas próximas.</p>
            )}
          </div>
        )}

        {userRole === 'student' && (
          <>
            {/* Room Booking */}
            <div className="bg-[#008899] rounded-xl p-4 mb-4 shadow-sm">
              <h3 className="text-white mb-2" style={{ fontWeight: 600 }}>RESERVA DE SALAS</h3>
              <p className="text-white text-xs opacity-90 mb-3">Encuentra un espacio para estudiar, reunirte o trabajar en equipo</p>
              <button
                onClick={() => navigate('/rooms')}
                className="bg-white text-[#008899] px-4 py-2 rounded-lg text-sm w-full hover:bg-gray-50 transition-colors"
                style={{ fontWeight: 500 }}
              >
                Reservar sala
              </button>
            </div>

            {/* Tutoring */}
            <div className="bg-white rounded-xl p-4 mb-4 shadow-sm">
              <h3 className="text-[#008899] mb-2" style={{ fontWeight: 600 }}>TUTORÍAS</h3>
              <p className="text-gray-500 text-xs mb-3">Reserva una tutoría con tu profesor o tutor académico</p>
              <p className="text-sm text-gray-500 mb-3">No tienes tutorías programadas.</p>
              <button
                disabled
                className="bg-gray-200 text-gray-500 px-4 py-2 rounded-lg text-sm w-full opacity-60"
                style={{ fontWeight: 500 }}
              >
                Pedir tutoría
              </button>
            </div>
          </>
        )}

        {/* Recent Content */}
        <div className="bg-white rounded-xl p-4 mb-4 shadow-sm">
          <h3 className="text-[#008899] mb-3" style={{ fontWeight: 600 }}>CONTENIDO RECIENTE</h3>
          <p className="text-sm text-gray-500">No hay contenido reciente.</p>
        </div>
      </div>
    </div>
  );
}
