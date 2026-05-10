import { Activity, AlertCircle, BarChart3, CalendarClock, CheckCircle2, Clock, Database, GraduationCap, Server, Users, type LucideIcon } from 'lucide-react';
import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router';
import {
  getMetricsAcademic,
  getMetricsHealth,
  getMetricsSummary,
  type AcademicMetricRow,
  type MetricsAcademic,
  type MetricsHealth,
  type MetricsSummary,
  type MetricValue,
  type ServiceHealth,
} from '../api/client';
import { CenteredLoadingSpinner } from './ui/LoadingSpinner';

const formatNumber = (metric?: MetricValue, suffix = ''): string => {
  if (!metric || metric.value === null || metric.value === undefined) return 'Sin datos';
  if (typeof metric.value === 'number') return `${metric.value.toLocaleString('es-ES')}${suffix}`;
  return `${metric.value}${suffix}`;
};

const formatDateTime = (value?: string | null): string => {
  if (!value) return 'No disponible';
  return new Intl.DateTimeFormat('es-ES', {
    day: '2-digit',
    month: 'short',
    hour: '2-digit',
    minute: '2-digit',
  }).format(new Date(value));
};

function StatusPill({ status }: { status: string }) {
  const normalized = status.toLowerCase();
  const isOk = ['ok', 'active', 'connected'].includes(normalized);
  const isUnknown = normalized === 'unknown' || normalized === 'empty';
  const classes = isOk
    ? 'bg-emerald-50 text-emerald-700 border-emerald-100'
    : isUnknown
      ? 'bg-amber-50 text-amber-700 border-amber-100'
      : 'bg-rose-50 text-rose-700 border-rose-100';
  return <span className={`px-2.5 py-1 rounded-full border text-xs ${classes}`}>{status}</span>;
}

function KpiCard({ icon: Icon, title, metric, suffix = '' }: { icon: LucideIcon; title: string; metric?: MetricValue; suffix?: string }) {
  const isProblem = metric?.status === 'error' || metric?.status === 'empty';
  return (
    <div className="bg-white rounded-2xl p-4 shadow-sm border border-gray-100">
      <div className="flex items-start justify-between gap-3">
        <div className="h-11 w-11 rounded-2xl bg-[#008899]/10 flex items-center justify-center">
          <Icon size={22} className="text-[#008899]" />
        </div>
        {metric && <StatusPill status={metric.status} />}
      </div>
      <p className="text-gray-500 text-xs mt-4">{title}</p>
      <p className="text-gray-900 text-2xl mt-1" style={{ fontWeight: 800 }}>{formatNumber(metric, suffix)}</p>
      {isProblem && metric?.message && <p className="text-xs text-gray-500 mt-2">{metric.message}</p>}
    </div>
  );
}

function HealthCard({ icon: Icon, service }: { icon: LucideIcon; service: ServiceHealth }) {
  return (
    <div className="bg-white rounded-2xl p-4 border border-gray-100 shadow-sm">
      <div className="flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="h-10 w-10 rounded-2xl bg-[#008899]/10 flex items-center justify-center">
            <Icon size={20} className="text-[#008899]" />
          </div>
          <div>
            <p className="text-gray-900 text-sm" style={{ fontWeight: 800 }}>{service.name}</p>
            <p className="text-gray-500 text-xs">{formatDateTime(service.checked_at)}</p>
          </div>
        </div>
        <StatusPill status={service.status} />
      </div>
      {service.message && <p className="text-gray-500 text-xs mt-3">{service.message}</p>}
    </div>
  );
}

function MetricTable({ title, rows }: { title: string; rows: AcademicMetricRow[] }) {
  return (
    <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
      <div className="p-4 border-b border-gray-100">
        <h3 className="text-gray-900 text-sm" style={{ fontWeight: 800 }}>{title}</h3>
      </div>
      {rows.length === 0 ? (
        <p className="p-4 text-sm text-gray-500">No hay datos disponibles todavia.</p>
      ) : (
        <div className="divide-y divide-gray-100">
          {rows.slice(0, 8).map((row) => (
            <div key={row.id} className="p-4 grid grid-cols-2 sm:grid-cols-4 gap-3 text-sm">
              <div className="col-span-2">
                <p className="text-gray-900" style={{ fontWeight: 700 }}>{row.nombre}</p>
                <p className="text-xs text-gray-500">{row.id}</p>
              </div>
              <div>
                <p className="text-xs text-gray-500">Estudiantes</p>
                <p className="text-gray-900" style={{ fontWeight: 700 }}>{row.estudiantes}</p>
              </div>
              <div>
                <p className="text-xs text-gray-500">Asistencia</p>
                <p className="text-gray-900" style={{ fontWeight: 700 }}>
                  {row.asistencia_media === null ? 'Sin datos' : `${row.asistencia_media}%`}
                </p>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export function CloudMetricsDashboard() {
  const navigate = useNavigate();
  const userRole = localStorage.getItem('userRole') || 'student';
  const [summary, setSummary] = useState<MetricsSummary | null>(null);
  const [academic, setAcademic] = useState<MetricsAcademic | null>(null);
  const [health, setHealth] = useState<MetricsHealth | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (userRole !== 'admin') {
      setLoading(false);
      return;
    }
    Promise.allSettled([getMetricsSummary(), getMetricsAcademic(), getMetricsHealth()])
      .then(([summaryResult, academicResult, healthResult]) => {
        if (summaryResult.status === 'fulfilled') setSummary(summaryResult.value);
        if (academicResult.status === 'fulfilled') setAcademic(academicResult.value);
        if (healthResult.status === 'fulfilled') setHealth(healthResult.value);
        const failed = [summaryResult, academicResult, healthResult].filter((result) => result.status === 'rejected');
        if (failed.length === 3) setError('No se pudieron cargar las metricas del dashboard.');
      })
      .finally(() => setLoading(false));
  }, [userRole]);

  const lastUpdated = useMemo(() => summary?.ultima_actualizacion || health?.ultima_actualizacion || null, [summary, health]);

  if (userRole !== 'developer') {
    return (
      <div className="min-h-screen bg-[#f5f5f5] px-6 pt-12 pb-24">
        <button onClick={() => navigate('/dashboard')} className="text-[#008899] text-sm mb-6">Volver</button>
        <div className="bg-white rounded-2xl p-6 border border-gray-100">
          <AlertCircle className="text-amber-600 mb-3" size={28} />
          <h1 className="text-gray-900 text-xl" style={{ fontWeight: 800 }}>Acceso no autorizado</h1>
          <p className="text-gray-500 text-sm mt-2">Este dashboard esta disponible solo para la cuenta de desarrollador.</p>
        </div>
      </div>
    );
  }

  if (loading) return <CenteredLoadingSpinner label="Cargando metricas..." />;

  return (
    <div className="min-h-screen bg-[#f5f5f5] pb-24">
      <div className="bg-[#008899] px-6 pt-12 pb-16 rounded-b-3xl">
        <button onClick={() => navigate('/dashboard')} className="text-white/90 text-sm mb-5">Volver</button>
        <h1 className="text-white text-2xl" style={{ fontWeight: 800 }}>Dashboard Cloud de Metricas</h1>
        <p className="text-white/85 text-sm mt-2">Seguimiento academico, operativo y tecnico de la plataforma</p>
      </div>

      <div className="px-6 -mt-10 space-y-5">
        {error && (
          <div className="bg-rose-50 text-rose-700 border border-rose-100 rounded-2xl p-4 text-sm">{error}</div>
        )}

        <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
          <KpiCard icon={Users} title="Estudiantes" metric={summary?.total_estudiantes} />
          <KpiCard icon={GraduationCap} title="Profesores" metric={summary?.total_profesores} />
          <KpiCard icon={Users} title="Coordinadores" metric={summary?.total_coordinadores} />
          <KpiCard icon={CalendarClock} title="Sesiones proximas" metric={summary?.sesiones_proximas} />
        </div>

        <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
          <KpiCard icon={BarChart3} title="Asistencia media" metric={summary?.asistencia_media} suffix={summary?.asistencia_media.value === null ? '' : '%'} />
          <KpiCard icon={Activity} title="Notas pendientes" metric={summary?.notas_pendientes} />
          <KpiCard icon={Clock} title="Tutorias pendientes" metric={summary?.tutorias_pendientes} />
          <div className="bg-white rounded-2xl p-4 shadow-sm border border-gray-100">
            <div className="h-11 w-11 rounded-2xl bg-[#008899]/10 flex items-center justify-center">
              <CheckCircle2 size={22} className="text-[#008899]" />
            </div>
            <p className="text-gray-500 text-xs mt-4">Ultima actualizacion</p>
            <p className="text-gray-900 text-lg mt-1" style={{ fontWeight: 800 }}>{formatDateTime(lastUpdated)}</p>
          </div>
        </div>

        <div className="grid lg:grid-cols-2 gap-4">
          <MetricTable title="Metricas por grupo" rows={academic?.por_grupo || []} />
          <MetricTable title="Metricas por asignatura" rows={academic?.por_asignatura || []} />
        </div>

        <div>
          <h2 className="text-gray-900 text-base mb-3" style={{ fontWeight: 800 }}>Estado cloud</h2>
          <div className="grid md:grid-cols-3 gap-3">
            {health ? (
              <>
                <HealthCard icon={Server} service={health.backend} />
                <HealthCard icon={Database} service={health.database} />
                <HealthCard icon={Activity} service={health.agent} />
              </>
            ) : (
              <p className="bg-white rounded-2xl p-4 text-sm text-gray-500 md:col-span-3">No hay datos de estado tecnico disponibles todavia.</p>
            )}
          </div>
        </div>

        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
          <div className="p-4 border-b border-gray-100">
            <h2 className="text-gray-900 text-base" style={{ fontWeight: 800 }}>Actividad reciente</h2>
          </div>
          {(academic?.actividad_reciente || []).length === 0 ? (
            <p className="p-4 text-sm text-gray-500">No hay actividad reciente disponible todavia.</p>
          ) : (
            <div className="divide-y divide-gray-100">
              {academic!.actividad_reciente.map((item, index) => (
                <div key={`${item.tipo}-${index}`} className="p-4 flex items-center justify-between gap-4">
                  <div>
                    <p className="text-gray-900 text-sm" style={{ fontWeight: 700 }}>{item.titulo}</p>
                    <p className="text-gray-500 text-xs">{item.detalle || 'Sin detalle'}</p>
                  </div>
                  <p className="text-gray-400 text-xs text-right">{formatDateTime(item.fecha)}</p>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
