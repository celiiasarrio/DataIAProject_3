import { ChevronLeft, Save, Check } from 'lucide-react';
import { useNavigate, useParams } from 'react-router';
import { useState } from 'react';

// Re-using mock data from GradingScreen for consistency
const mockStudents = [
  { id: '101', name: 'Elena García' },
  { id: '102', name: 'Marcos Alonso' },
  { id: '103', name: 'Sofía Navarro' },
  { id: '104', name: 'Javier Ortiz' },
  { id: '105', name: 'Lucía Jiménez' },
  { id: '106', name: 'Paco Pérez' },
];

// Re-using session names from other screens
const sessionNames: Record<string, string> = {
  'bda-301': 'Big Data & Analytics',
  'mkt-201': 'Marketing Digital',
  'fin-302': 'Finanzas Corporativas',
  'est-401': 'Estrategia Empresarial',
};

export function ClassAttendanceScreen() {
  const navigate = useNavigate();
  const { sessionId } = useParams<{ sessionId: string }>();
  // State to hold attendance. Key is studentId, value is boolean (present or not)
  const [attendance, setAttendance] = useState<Record<string, boolean>>({});

  const sessionName = sessionId ? sessionNames[sessionId] || 'Sesión' : 'Sesión';

  const handleAttendanceChange = (studentId: string) => {
    setAttendance(prev => ({ ...prev, [studentId]: !prev[studentId] }));
  };

  const allPresent = mockStudents.every(student => attendance[student.id]);

  const toggleAll = () => {
    const newAttendance = mockStudents.reduce((acc, student) => {
      acc[student.id] = !allPresent;
      return acc;
    }, {} as Record<string, boolean>);
    setAttendance(newAttendance);
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
            <h1 className="text-white text-xl" style={{ fontWeight: 600 }}>Pasar Asistencia</h1>
            <p className="text-white text-xs opacity-80">{sessionName}</p>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="bg-white rounded-t-3xl px-5 pt-5 pb-6 min-h-[70vh]">
        <div className="flex justify-end mb-4">
            <button onClick={toggleAll} className="text-sm text-[#008899]" style={{fontWeight: 600}}>
                {allPresent ? 'Desmarcar todos' : 'Marcar todos como presentes'}
            </button>
        </div>
        <div className="space-y-3 mb-6">
          {mockStudents.map((student) => (
            <div key={student.id} onClick={() => handleAttendanceChange(student.id)} className={`flex items-center justify-between gap-4 rounded-2xl p-4 transition-colors cursor-pointer ${attendance[student.id] ? 'bg-green-50' : 'bg-gray-50'}`}>
              <p className={`flex-1 transition-colors ${attendance[student.id] ? 'text-gray-800' : 'text-gray-500'}`}>{student.name}</p>
              <div className={`w-6 h-6 rounded-md flex items-center justify-center border-2 transition-all ${attendance[student.id] ? 'bg-[#008899] border-[#008899]' : 'border-gray-300'}`}>
                {attendance[student.id] && <Check size={16} className="text-white" />}
              </div>
            </div>
          ))}
        </div>
        <button className="w-full bg-[#008899] text-white py-3 rounded-lg flex items-center justify-center gap-2 hover:bg-[#007788] transition-colors">
          <Save size={16} />
          Guardar Asistencia
        </button>
      </div>
    </div>
  );
}
