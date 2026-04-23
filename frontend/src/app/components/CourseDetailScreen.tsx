import { useState } from 'react';
import { ChevronLeft, ChevronDown, Edit } from 'lucide-react';
import { useNavigate, useParams } from 'react-router';

const mockSessions: Record<string, { id: string; name: string }[]> = {
  'ade-data': [
    { id: 'bda-301', name: 'Big Data & Analytics' },
    { id: 'mkt-201', name: 'Marketing Digital' },
    { id: 'fin-302', name: 'Finanzas Corporativas' },
    { id: 'est-401', name: 'Estrategia Empresarial' },
  ],
  'big-data': [
    { id: 'py-101', name: 'Python para Data Science' },
    { id: 'ml-201', name: 'Machine Learning I' },
  ],
  'digital-marketing': [
    { id: 'seo-101', name: 'SEO y SEM' },
    { id: 'sm-201', name: 'Social Media Strategy' },
  ],
};

const courseNames: Record<string, string> = {
  'ade-data': 'Grado ADE + DATA',
  'big-data': 'Máster en Big Data y Analytics',
  'digital-marketing': 'Máster en Marketing Digital',
}

export function CourseDetailScreen() {
  const navigate = useNavigate();
  const { courseId } = useParams<{ courseId: string }>();
  const [openSession, setOpenSession] = useState<string | null>(null);

  const sessions = courseId ? mockSessions[courseId] || [] : [];
  const courseName = courseId ? courseNames[courseId] || 'Curso' : 'Curso';

  const toggleSession = (sessionId: string) => {
    setOpenSession(openSession === sessionId ? null : sessionId);
  };

  return (
    <div className="min-h-screen bg-[#008899] pb-20">
      {/* Header */}
      <div className="px-5 pt-12 pb-6">
        <div className="flex items-center gap-3">
          <button onClick={() => navigate(-1)} className="p-1">
            <ChevronLeft className="text-white" size={24} />
          </button>
          <div>
            <h1 className="text-white text-xl" style={{ fontWeight: 600 }}>{courseName}</h1>
            <p className="text-white text-xs opacity-80">Sesiones del curso</p>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="bg-white rounded-t-3xl px-5 pt-5 pb-6 min-h-[70vh]">
        <div className="space-y-2">
          {sessions.map((session) => (
            <div key={session.id} className="bg-gray-50 rounded-2xl">
              <button
                onClick={() => toggleSession(session.id)}
                className="w-full flex items-center justify-between p-4 text-left"
              >
                <span className="text-gray-800" style={{ fontWeight: 600 }}>{session.name}</span>
                <ChevronDown size={20} className={`text-gray-500 transition-transform ${openSession === session.id ? 'rotate-180' : ''}`} />
              </button>
              {openSession === session.id && (
                <div className="px-4 pb-4">
                  <button onClick={() => navigate(`/courses/${courseId}/sessions/${session.id}/grade`)} className="w-full bg-[#008899] text-white py-2 rounded-lg text-sm flex items-center justify-center gap-2 hover:bg-[#007788] transition-colors">
                    <Edit size={14} />
                    Calificar
                  </button>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
