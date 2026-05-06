import { useEffect, useMemo, useState } from 'react';
import { CalendarDays, ChevronLeft, Clock, FileText } from 'lucide-react';
import { useNavigate } from 'react-router';
import { getCalendarEvents, type CalendarEvent } from '../api/client';

const getDayKey = (value: string | Date) => {
  const date = typeof value === 'string' ? new Date(value) : value;
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
};

const formatDate = (value: string) =>
  new Intl.DateTimeFormat('es-ES', {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
  }).format(new Date(value));

const formatTime = (value: string) =>
  new Intl.DateTimeFormat('es-ES', {
    hour: '2-digit',
    minute: '2-digit',
  }).format(new Date(value));

function daysFromNow(value: string) {
  const target = new Date(value);
  target.setHours(0, 0, 0, 0);
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  return Math.ceil((target.getTime() - today.getTime()) / 86_400_000);
}

function dueLabel(days: number) {
  if (days === 0) return 'Hoy';
  if (days === 1) return 'Mañana';
  return `En ${days} días`;
}

function DeadlineBadge({ days }: { days: number }) {
  const urgent = days <= 1;

  return (
    <span
      className={`rounded-full px-2.5 py-1 text-xs font-semibold ${
        urgent ? 'bg-amber-100 text-amber-700' : 'bg-gray-100 text-gray-600'
      }`}
    >
      {dueLabel(days)}
    </span>
  );
}

export function TasksScreen() {
  const navigate = useNavigate();
  const [events, setEvents] = useState<CalendarEvent[]>([]);
  const [loading, setLoading] = useState(true);

  const today = getDayKey(new Date());

  useEffect(() => {
    getCalendarEvents()
      .then(setEvents)
      .catch(() => setEvents([]))
      .finally(() => setLoading(false));
  }, []);

  const remainingDeliveries = useMemo(
    () =>
      events
        .filter((event) => event.tipo === 'delivery' && getDayKey(event.fecha_inicio) >= today)
        .sort((a, b) => a.fecha_inicio.localeCompare(b.fecha_inicio)),
    [events, today],
  );

  return (
    <div className="min-h-screen bg-[#008899] pb-20">
      <div className="px-5 pt-12 pb-6">
        <div className="flex items-center gap-3">
          <button onClick={() => navigate(-1)} className="p-1">
            <ChevronLeft className="text-white" size={24} />
          </button>
          <div>
            <h1 className="text-white text-xl" style={{ fontWeight: 600 }}>Entregas restantes</h1>
            <p className="text-white text-xs opacity-80">
              {loading ? 'Cargando entregas' : `${remainingDeliveries.length} pendientes`}
            </p>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-t-3xl px-4 pt-5 pb-6 min-h-[78vh]">
        {loading ? (
          <div className="space-y-3">
            {[0, 1, 2].map((item) => (
              <div key={item} className="h-24 animate-pulse rounded-2xl bg-gray-100" />
            ))}
          </div>
        ) : remainingDeliveries.length === 0 ? (
          <div className="flex min-h-[50vh] flex-col items-center justify-center text-center">
            <div className="mb-3 rounded-2xl bg-gray-100 p-4">
              <FileText size={28} className="text-gray-400" />
            </div>
            <p className="text-sm font-semibold text-gray-800">No hay entregas pendientes</p>
            <p className="mt-1 text-xs text-gray-400">Cuando aparezcan nuevas entregas, las verás aquí.</p>
          </div>
        ) : (
          <div className="space-y-3">
            {remainingDeliveries.map((delivery) => {
              const days = daysFromNow(delivery.fecha_inicio);
              const urgent = days <= 1;

              return (
                <article
                  key={delivery.id}
                  className={`rounded-2xl p-4 shadow-sm ${
                    urgent ? 'border border-amber-200 bg-amber-50' : 'border border-gray-100 bg-white'
                  }`}
                >
                  <div className="flex items-start gap-3">
                    <div className={`rounded-xl p-2.5 ${urgent ? 'bg-amber-100' : 'bg-amber-50'}`}>
                      <FileText size={18} className="text-amber-600" />
                    </div>
                    <div className="min-w-0 flex-1">
                      <div className="flex items-start justify-between gap-3">
                        <div className="min-w-0">
                          <h2 className="text-sm font-semibold leading-tight text-gray-900">{delivery.titulo}</h2>
                          <p className="mt-1 text-xs text-gray-400">
                            {delivery.bloque_nombre ?? delivery.id_bloque ?? 'Sin bloque'}
                          </p>
                        </div>
                        <DeadlineBadge days={days} />
                      </div>

                      <div className="mt-3 flex flex-wrap items-center gap-x-4 gap-y-1 text-xs text-gray-500">
                        <span className="flex items-center gap-1 capitalize">
                          <CalendarDays size={12} />
                          {formatDate(delivery.fecha_inicio)}
                        </span>
                        <span className="flex items-center gap-1">
                          <Clock size={12} />
                          {formatTime(delivery.fecha_inicio)}
                        </span>
                      </div>

                      {delivery.descripcion && (
                        <p className="mt-3 text-xs leading-relaxed text-gray-600">{delivery.descripcion}</p>
                      )}
                    </div>
                  </div>
                </article>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}
