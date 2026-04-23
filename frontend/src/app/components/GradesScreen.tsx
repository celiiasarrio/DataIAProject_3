import { useState, useEffect } from 'react';
import { ChevronLeft, TrendingUp, Award, BookOpen, ChevronDown, ChevronUp } from 'lucide-react';
import { useNavigate } from 'react-router';
import { getMyGrades, type GradeOut } from '../api/client';

interface SessionGroup {
  id_sesion: string;
  grades: GradeOut[];
  average: number;
}

const getGradeLabel = (g: number) => {
  if (g >= 9)    return { label: 'Sobresaliente', color: 'text-purple-600', bg: 'bg-purple-50' };
  if (g >= 7)    return { label: 'Notable',       color: 'text-blue-600',   bg: 'bg-blue-50'   };
  if (g >= 6)    return { label: 'Bien',           color: 'text-green-600',  bg: 'bg-green-50'  };
  if (g >= 5)    return { label: 'Aprobado',       color: 'text-amber-600',  bg: 'bg-amber-50'  };
  return              { label: 'Suspenso',        color: 'text-red-600',    bg: 'bg-red-50'    };
};

export function GradesScreen() {
  const navigate = useNavigate();
  const [expandedIndex, setExpandedIndex] = useState<number | null>(null);
  const [sessions, setSessions] = useState<SessionGroup[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getMyGrades()
      .then((grades) => {
        // Group grades by session
        const map = new Map<string, GradeOut[]>();
        for (const g of grades) {
          const list = map.get(g.id_sesion) || [];
          list.push(g);
          map.set(g.id_sesion, list);
        }
        const grouped: SessionGroup[] = Array.from(map.entries()).map(([id_sesion, gradeList]) => {
          const avg = gradeList.reduce((acc, g) => acc + g.nota, 0) / gradeList.length;
          return { id_sesion, grades: gradeList, average: avg };
        });
        setSessions(grouped);
      })
      .catch(() => setSessions([]))
      .finally(() => setLoading(false));
  }, []);

  const average = sessions.length > 0
    ? sessions.reduce((acc, s) => acc + s.average, 0) / sessions.length
    : 0;

  const { label: avgLabel, color: avgColor, bg: avgBg } = getGradeLabel(average);

  return (
    <div className="min-h-screen bg-[#008899] pb-20">
      {/* ── Header ── */}
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

        {/* Average summary */}
        <div className="bg-white/15 rounded-2xl p-4 flex items-center gap-4">
          <div className="w-14 h-14 rounded-2xl bg-white flex items-center justify-center shadow">
            <span className="text-[#008899] text-xl" style={{ fontWeight: 800 }}>
              {average > 0 ? average.toFixed(1) : '—'}
            </span>
          </div>
          <div>
            <p className="text-white/70 text-xs mb-0.5">Nota Media Global</p>
            <p className="text-white text-base" style={{ fontWeight: 700 }}>{average > 0 ? avgLabel : '—'}</p>
            <p className="text-white/60 text-xs">{sessions.length} sesiones · Curso 2025–26</p>
          </div>
          <TrendingUp className="text-white/60 ml-auto" size={28} />
        </div>
      </div>

      {/* ── Content ── */}
      <div className="bg-white rounded-t-3xl px-5 pt-5 pb-6 min-h-[70vh]">
        <div className="flex items-center gap-2 mb-5">
          <BookOpen size={18} className="text-[#008899]" />
          <h2 className="text-[#008899]" style={{ fontWeight: 700 }}>MIS NOTAS</h2>
        </div>

        {loading ? (
          <p className="text-gray-400 text-sm text-center py-8">Cargando notas...</p>
        ) : sessions.length === 0 ? (
          <p className="text-gray-400 text-sm text-center py-8">No hay notas disponibles.</p>
        ) : (
          <div className="space-y-3">
            {sessions.map((session, i) => {
              const { label, color, bg } = getGradeLabel(session.average);
              const isExpanded = expandedIndex === i;

              return (
                <div
                  key={session.id_sesion}
                  className="bg-gray-50 rounded-2xl p-4 cursor-pointer hover:bg-gray-100 transition-colors"
                  onClick={() => setExpandedIndex(isExpanded ? null : i)}
                >
                  <div className="flex items-start justify-between">
                    <div className="flex-1 min-w-0 mr-3">
                      <p className="text-gray-800 text-sm truncate" style={{ fontWeight: 600 }}>
                        {session.id_sesion}
                      </p>
                      <p className="text-xs text-gray-400 mt-0.5">{session.grades.length} entrega(s)</p>
                    </div>
                    <div className="text-right flex-shrink-0 flex items-center gap-3">
                      <div>
                        <p className="text-gray-800 text-lg text-right" style={{ fontWeight: 800 }}>
                          {session.average.toFixed(1)}
                        </p>
                        <span className={`text-xs px-2 py-0.5 rounded-full ${bg} ${color} inline-block mt-0.5`} style={{ fontWeight: 600 }}>
                          {label}
                        </span>
                      </div>
                      {isExpanded ? <ChevronUp size={20} className="text-gray-400" /> : <ChevronDown size={20} className="text-gray-400" />}
                    </div>
                  </div>

                  {isExpanded && (
                    <div className="mt-4 pt-4 border-t border-gray-200 space-y-3">
                      {session.grades.map((g) => (
                        <div key={g.id_tarea} className="flex items-center justify-between">
                          <span className="text-sm text-gray-600">{g.nombre_tarea}</span>
                          <span className="text-sm text-gray-800" style={{ fontWeight: 600 }}>{g.nota.toFixed(1)}</span>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        )}

        {/* Stats row */}
        {sessions.length > 0 && (
          <div className="grid grid-cols-3 gap-3 mt-5">
            {[
              { icon: Award,     label: 'Mejor nota',  value: Math.max(...sessions.map(s => s.average)).toFixed(1), sub: 'Sesión' },
              { icon: TrendingUp, label: 'Media',      value: average.toFixed(2), sub: 'Global' },
              { icon: BookOpen,  label: 'Sesiones', value: sessions.length.toString(), sub: 'Total' },
            ].map(({ icon: Icon, label, value, sub }, i) => (
              <div key={i} className="bg-[#008899]/5 rounded-2xl p-3 text-center">
                <Icon size={18} className="text-[#008899] mx-auto mb-1" />
                <p className="text-[#008899] text-base" style={{ fontWeight: 800 }}>{value}</p>
                <p className="text-gray-500 text-xs">{label}</p>
                <p className="text-gray-400 text-xs">{sub}</p>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
