import { useState, useEffect } from 'react';
import { BookOpen, ChevronDown, ChevronLeft, ChevronUp, TrendingUp } from 'lucide-react';
import { useNavigate } from 'react-router';
import { getMyGrades, type GradeOut } from '../api/client';

interface GradeCategory {
  id: string;
  label: string;
  weight: number;
  grades: GradeOut[];
  average: number | null;
}

const CATEGORY_ORDER = [
  { id: 'entregables', label: 'Entregables', weight: 20 },
  { id: 'data_projects', label: 'Data Projects', weight: 30 },
  { id: 'actitud', label: 'Actitud y valores', weight: 10 },
  { id: 'tfm', label: 'TFM', weight: 40 },
];

const getGradeLabel = (g: number) => {
  if (g >= 9) return { label: 'Sobresaliente', color: 'text-purple-600', bg: 'bg-purple-50' };
  if (g >= 7) return { label: 'Notable', color: 'text-blue-600', bg: 'bg-blue-50' };
  if (g >= 6) return { label: 'Bien', color: 'text-green-600', bg: 'bg-green-50' };
  if (g >= 5) return { label: 'Aprobado', color: 'text-amber-600', bg: 'bg-amber-50' };
  return { label: 'Suspenso', color: 'text-red-600', bg: 'bg-red-50' };
};

const categoryAverage = (grades: GradeOut[]) => {
  if (grades.length === 0) return null;
  return grades.reduce((acc, grade) => acc + grade.nota, 0) / grades.length;
};

function GradeWheel({ category }: { category: GradeCategory }) {
  const score = category.average;
  const progress = score == null ? 0 : Math.max(0, Math.min(100, score * 10));

  return (
    <div className="bg-white rounded-2xl p-3 shadow-sm border border-gray-100">
      <div
        className="w-16 h-16 rounded-full mx-auto flex items-center justify-center"
        style={{
          background: `conic-gradient(#008899 ${progress}%, #e5e7eb ${progress}% 100%)`,
        }}
      >
        <div className="w-12 h-12 rounded-full bg-white flex items-center justify-center">
          <span className="text-[#008899] text-sm" style={{ fontWeight: 800 }}>
            {score == null ? '-' : score.toFixed(1)}
          </span>
        </div>
      </div>
      <p className="text-gray-800 text-xs text-center mt-2 leading-tight" style={{ fontWeight: 700 }}>
        {category.label}
      </p>
      <p className="text-gray-400 text-xs text-center">{category.weight}%</p>
    </div>
  );
}

export function GradesScreen() {
  const navigate = useNavigate();
  const [expandedIndex, setExpandedIndex] = useState<number | null>(0);
  const [categories, setCategories] = useState<GradeCategory[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getMyGrades()
      .then((grades) => {
        const grouped = CATEGORY_ORDER.map((category) => {
          const categoryGrades = grades.filter((grade) => grade.categoria === category.id);
          return {
            ...category,
            grades: categoryGrades,
            average: categoryAverage(categoryGrades),
          };
        });
        setCategories(grouped);
      })
      .catch(() => setCategories([]))
      .finally(() => setLoading(false));
  }, []);

  const gradedCategories = categories.filter((category) => category.average !== null);
  const availableWeight = gradedCategories.reduce((acc, category) => acc + category.weight, 0);
  const weightedAverage = availableWeight > 0
    ? gradedCategories.reduce((acc, category) => acc + (category.average ?? 0) * category.weight, 0) / availableWeight
    : 0;
  const { label: avgLabel } = getGradeLabel(weightedAverage);

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

        <div className="bg-white/15 rounded-2xl p-4 flex items-center gap-4">
          <div className="w-14 h-14 rounded-2xl bg-white flex items-center justify-center shadow">
            <span className="text-[#008899] text-xl" style={{ fontWeight: 800 }}>
              {availableWeight > 0 ? weightedAverage.toFixed(1) : '-'}
            </span>
          </div>
          <div>
            <p className="text-white/70 text-xs mb-0.5">Nota global publicada</p>
            <p className="text-white text-base" style={{ fontWeight: 700 }}>{availableWeight > 0 ? avgLabel : '-'}</p>
            <p className="text-white/60 text-xs">{availableWeight}% evaluado del curso</p>
          </div>
          <TrendingUp className="text-white/60 ml-auto" size={28} />
        </div>
      </div>

      <div className="bg-white rounded-t-3xl px-5 pt-5 pb-6 min-h-[70vh]">
        <div className="flex items-center gap-2 mb-5">
          <BookOpen size={18} className="text-[#008899]" />
          <h2 className="text-[#008899]" style={{ fontWeight: 700 }}>MIS NOTAS</h2>
        </div>

        {loading ? (
          <p className="text-gray-400 text-sm text-center py-8">Cargando notas...</p>
        ) : (
          <>
            <div className="grid grid-cols-2 gap-3 mb-5">
              {categories.map((category) => (
                <GradeWheel key={category.id} category={category} />
              ))}
            </div>

            <div className="space-y-3">
              {categories.map((category, i) => {
                const isExpanded = expandedIndex === i;
                const hasGrade = category.average !== null;
                const gradeMeta = hasGrade ? getGradeLabel(category.average ?? 0) : null;

                return (
                  <div
                    key={category.id}
                    className="bg-gray-50 rounded-2xl p-4 cursor-pointer hover:bg-gray-100 transition-colors"
                    onClick={() => setExpandedIndex(isExpanded ? null : i)}
                  >
                    <div className="flex items-start justify-between">
                      <div className="flex-1 min-w-0 mr-3">
                        <p className="text-gray-800 text-sm truncate" style={{ fontWeight: 700 }}>
                          {category.label}
                        </p>
                        <p className="text-xs text-gray-400 mt-0.5">
                          {category.weight}% · {category.grades.length > 0 ? `${category.grades.length} nota(s)` : 'Pendiente'}
                        </p>
                      </div>
                      <div className="text-right flex-shrink-0 flex items-center gap-3">
                        <div>
                          <p className="text-gray-800 text-lg text-right" style={{ fontWeight: 800 }}>
                            {hasGrade ? category.average?.toFixed(1) : '-'}
                          </p>
                          <span className={`text-xs px-2 py-0.5 rounded-full inline-block mt-0.5 ${
                            gradeMeta ? `${gradeMeta.bg} ${gradeMeta.color}` : 'bg-gray-100 text-gray-400'
                          }`} style={{ fontWeight: 600 }}>
                            {gradeMeta ? gradeMeta.label : 'Pendiente'}
                          </span>
                        </div>
                        {isExpanded ? <ChevronUp size={20} className="text-gray-400" /> : <ChevronDown size={20} className="text-gray-400" />}
                      </div>
                    </div>

                    {isExpanded && (
                      <div className="mt-4 pt-4 border-t border-gray-200 space-y-3">
                        {category.grades.length === 0 ? (
                          <p className="text-sm text-gray-400">Aún no hay notas publicadas.</p>
                        ) : (
                          category.grades.map((grade) => (
                            <div key={grade.id_tarea} className="flex items-center justify-between gap-4">
                              <span className="text-sm text-gray-600">{grade.nombre_tarea}</span>
                              <span className="text-sm text-gray-800" style={{ fontWeight: 700 }}>{grade.nota.toFixed(1)}</span>
                            </div>
                          ))
                        )}
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          </>
        )}
      </div>
    </div>
  );
}
