import { ChevronLeft, Save } from 'lucide-react';
import { useNavigate, useParams } from 'react-router';
import { useState } from 'react';

const mockStudents = [
  { id: '101', name: 'Elena García' },
  { id: '102', name: 'Marcos Alonso' },
  { id: '103', name: 'Sofía Navarro' },
  { id: '104', name: 'Javier Ortiz' },
  { id: '105', name: 'Lucía Jiménez' },
  { id: '106', name: 'Paco Pérez' },
];

const blockNames: Record<string, string> = {
  'bda-301': 'Big Data & Analytics',
  'mkt-201': 'Marketing Digital',
  'fin-302': 'Finanzas Corporativas',
  'est-401': 'Estrategia Empresarial',
  'py-101': 'Python para Data Science',
  'ml-201': 'Machine Learning I',
  'seo-101': 'SEO y SEM',
  'sm-201': 'Social Media Strategy',
};

export function GradingScreen() {
  const navigate = useNavigate();
  const { blockId } = useParams<{ blockId: string }>();
  const [grades, setGrades] = useState<Record<string, string>>({});

  const blockName = blockId ? blockNames[blockId] || 'Bloque' : 'Bloque';

  const handleGradeChange = (studentId: string, value: string) => {
    setGrades(prev => ({ ...prev, [studentId]: value }));
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
            <h1 className="text-white text-xl" style={{ fontWeight: 600 }}>Calificar</h1>
            <p className="text-white text-xs opacity-80">{blockName}</p>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="bg-white rounded-t-3xl px-5 pt-5 pb-6 min-h-[70vh]">
        <div className="space-y-3 mb-6">
          {mockStudents.map((student) => (
            <div key={student.id} className="flex items-center justify-between gap-4 bg-gray-50 rounded-2xl p-4">
              <p className="text-gray-800 flex-1">{student.name}</p>
              <input
                type="number"
                step="0.1"
                min="0"
                max="10"
                placeholder="-"
                value={grades[student.id] || ''}
                onChange={(e) => handleGradeChange(student.id, e.target.value)}
                className="w-20 text-center text-lg font-bold text-[#008899] bg-white border border-gray-200 rounded-lg p-2 focus:outline-none focus:ring-2 focus:ring-[#008899]"
              />
            </div>
          ))}
        </div>
        <button className="w-full bg-[#008899] text-white py-3 rounded-lg flex items-center justify-center gap-2 hover:bg-[#007788] transition-colors">
          <Save size={16} />
          Guardar Notas
        </button>
      </div>
    </div>
  );
}
