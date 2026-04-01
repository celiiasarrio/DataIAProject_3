import { ChevronLeft, BookOpen } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useState } from 'react';

interface Student {
  id: string;
  name: string;
  course: string;
  grade: number | null;
}

const initialStudents: Student[] = [
  { id: 'S001', name: 'Paco Pérez', course: 'Marketing Digital', grade: 7.2 },
  { id: 'S002', name: 'Ana López', course: 'Marketing Digital', grade: 8.5 },
  { id: 'S003', name: 'Carlos Sánchez', course: 'Marketing Digital', grade: null },
  { id: 'S004', name: 'Laura Martín', course: 'Finanzas Corporativas', grade: 9.0 },
  { id: 'S005', name: 'Javier Gómez', course: 'Finanzas Corporativas', grade: 6.8 },
];

export function TeacherGradesScreen() {
  const navigate = useNavigate();
  const [students, setStudents] = useState(initialStudents);
  const [courseFilter, setCourseFilter] = useState('Marketing Digital');

  const handleGradeChange = (studentId: string, newGrade: string) => {
    const gradeAsNumber = newGrade === '' ? null : parseFloat(newGrade);
    if (gradeAsNumber !== null && (isNaN(gradeAsNumber) || gradeAsNumber < 0 || gradeAsNumber > 10)) {
      return; // Invalid grade
    }
    setStudents(students.map(s => s.id === studentId ? { ...s, grade: gradeAsNumber } : s));
  };

  const filteredStudents = students.filter(s => s.course === courseFilter);

  return (
    <div className="min-h-screen bg-[#008899] pb-20">
      {/* Header */}
      <div className="px-5 pt-12 pb-6">
        <div className="flex items-center gap-3 mb-6">
          <button onClick={() => navigate(-1)} className="p-1">
            <ChevronLeft className="text-white" size={24} />
          </button>
          <div>
            <h1 className="text-white text-xl" style={{ fontWeight: 600 }}>Calificar Alumnos</h1>
          </div>
        </div>
        {/* Course filter */}
        <div className="bg-white/15 rounded-2xl p-2">
          <select
            value={courseFilter}
            onChange={(e) => setCourseFilter(e.target.value)}
            className="w-full bg-transparent text-white focus:outline-none"
          >
            <option value="Marketing Digital" className="text-black">Marketing Digital</option>
            <option value="Finanzas Corporativas" className="text-black">Finanzas Corporativas</option>
          </select>
        </div>
      </div>

      {/* Content */}
      <div className="bg-white rounded-t-3xl px-5 pt-5 pb-6 min-h-[70vh]">
        <div className="flex items-center gap-2 mb-5">
          <BookOpen size={18} className="text-[#008899]" />
          <h2 className="text-[#008899]" style={{ fontWeight: 700 }}>ALUMNOS DE {courseFilter.toUpperCase()}</h2>
        </div>

        <div className="space-y-3">
          {filteredStudents.map((student) => (
            <div key={student.id} className="bg-gray-50 rounded-2xl p-4 flex items-center justify-between">
              <div>
                <p className="text-gray-800 text-sm" style={{ fontWeight: 600 }}>{student.name}</p>
                <p className="text-xs text-gray-400">{student.id}</p>
              </div>
              <div className="flex items-center gap-2">
                <span className="text-sm text-gray-500">Nota:</span>
                <input
                  type="number"
                  step="0.1"
                  min="0"
                  max="10"
                  value={student.grade ?? ''}
                  onChange={(e) => handleGradeChange(student.id, e.target.value)}
                  placeholder="N/A"
                  className="w-20 text-center text-sm font-semibold bg-white border border-gray-300 rounded-md py-1 px-2 focus:outline-none focus:ring-2 focus:ring-[#008899]"
                />
              </div>
            </div>
          ))}
        </div>
        <button className="w-full bg-[#008899] text-white py-3 rounded-xl mt-6 hover:bg-[#007788] transition-colors">
          Guardar Cambios
        </button>
      </div>
    </div>
  );
}