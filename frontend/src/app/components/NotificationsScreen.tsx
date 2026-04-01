import { ChevronLeft, Calendar, Mail, Award, MapPin, AlertCircle, Clock } from 'lucide-react';
import { useNavigate } from 'react-router';

type NotifType = 'calendar' | 'email' | 'grade' | 'booking' | 'attendance';

interface Notification {
  id: number;
  type: NotifType;
  title: string;
  message: string;
  time: string;
  isRead: boolean;
}

const mockNotifications: Notification[] = [
  {
    id: 1,
    type: 'attendance',
    title: 'Aviso de Asistencia',
    message: 'Estás por debajo del 80% mínimo en Estrategia Empresarial. Revisa tus faltas.',
    time: 'Hace 1 hora',
    isRead: false,
  },
  {
    id: 2,
    type: 'calendar',
    title: 'Recordatorio de Examen',
    message: 'Mañana tienes el examen de Finanzas a las 12:00h en el Aula 3.',
    time: 'Hace 3 horas',
    isRead: false,
  },
  {
    id: 3,
    type: 'email',
    title: 'Nuevo correo de Coordinación',
    message: 'Importante: Abierto el plazo para la selección de TFG.',
    time: 'Ayer, 16:45',
    isRead: true,
  },
  {
    id: 4,
    type: 'grade',
    title: 'Nuevas Notas Publicadas',
    message: 'Se han publicado las notas de la entrega de Big Data & Analytics.',
    time: 'Ayer, 11:30',
    isRead: true,
  },
  {
    id: 5,
    type: 'booking',
    title: 'Reserva Confirmada',
    message: 'Tu reserva para la Sala EDEM 1 ha sido confirmada para el Viernes 27 de 10h a 12h.',
    time: 'Mar 24, 09:15',
    isRead: true,
  },
  {
    id: 6,
    type: 'calendar',
    title: 'Entrega Próxima',
    message: 'Recuerda subir el proyecto de Marketing Digital antes de esta noche.',
    time: 'Mar 23, 18:00',
    isRead: true,
  },
];

const TYPE_CONFIG: Record<NotifType, { icon: any; bg: string; color: string }> = {
  calendar:   { icon: Calendar,    bg: 'bg-blue-100',   color: 'text-blue-600' },
  email:      { icon: Mail,        bg: 'bg-purple-100', color: 'text-purple-600' },
  grade:      { icon: Award,       bg: 'bg-green-100',  color: 'text-green-600' },
  booking:    { icon: MapPin,      bg: 'bg-teal-100',   color: 'text-teal-600' },
  attendance: { icon: AlertCircle, bg: 'bg-red-100',    color: 'text-red-600' },
};

export function NotificationsScreen() {
  const navigate = useNavigate();

  return (
    <div className="min-h-screen bg-[#008899] pb-20 flex flex-col">
      {/* Header */}
      <div className="px-5 pt-12 pb-6 flex-shrink-0">
        <div className="flex items-center gap-3">
          <button onClick={() => navigate(-1)} className="p-1 active:scale-95 transition-transform">
            <ChevronLeft className="text-white" size={24} />
          </button>
          <div>
            <h1 className="text-white text-xl" style={{ fontWeight: 600 }}>Notificaciones</h1>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="bg-white rounded-t-3xl flex-1 px-5 pt-6 pb-6 shadow-inner">
        <div className="flex items-center justify-between mb-6">
          <p className="text-gray-500 text-sm">Tienes 2 notificaciones nuevas</p>
          <button className="text-[#008899] text-sm" style={{ fontWeight: 600 }}>
            Marcar todo como leído
          </button>
        </div>

        <div className="space-y-4">
          {mockNotifications.map((notif) => {
            const { icon: Icon, bg, color } = TYPE_CONFIG[notif.type];
            
            return (
              <div 
                key={notif.id} 
                className={`flex gap-4 p-4 rounded-2xl transition-all ${notif.isRead ? 'bg-gray-50' : 'bg-white shadow-sm border border-gray-100'}`}
              >
                <div className={`w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 ${bg}`}>
                  <Icon size={20} className={color} />
                </div>
                <div className="flex-1 min-w-0">
                  <h3 className={`text-sm mb-1 ${notif.isRead ? 'text-gray-700' : 'text-gray-900'}`} style={{ fontWeight: notif.isRead ? 500 : 700 }}>
                    {notif.title}
                  </h3>
                  <p className="text-gray-600 text-sm mb-2 leading-snug">{notif.message}</p>
                  <div className="flex items-center gap-1 text-xs text-gray-400">
                    <Clock size={12} />
                    <span>{notif.time}</span>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}