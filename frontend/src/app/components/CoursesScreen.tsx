import { ChevronLeft } from 'lucide-react';
import { useNavigate } from 'react-router';

const mockCourses = [
  { id: 'ade-data', name: 'Grado ADE + DATA', year: '2025-2026', studentCount: 120 },
  { id: 'big-data', name: 'Máster en Big Data y Analytics', year: '2025-2026', studentCount: 45 },
  { id: 'digital-marketing', name: 'Máster en Marketing Digital', year: '2025-2026', studentCount: 30 },
];

export function CoursesScreen() {
  const navigate = useNavigate();

  return (
    <div className="min-h-screen bg-[#008899] pb-20">
      {/* Header */}
      <div className="px-5 pt-12 pb-6">
        <div className="flex items-center gap-3">
          <button onClick={() => navigate(-1)} className="p-1">
            <ChevronLeft className="text-white" size={24} />
          </button>
          <div>
            <h1 className="text-white text-xl" style={{ fontWeight: 600 }}>Mis Cursos</h1>
            <p className="text-white text-xs opacity-80">Cursos asignados</p>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="bg-white rounded-t-3xl px-5 pt-5 pb-6 min-h-[70vh]">
        <div className="space-y-3">
          {mockCourses.map((course) => (
            <button
              key={course.id}
              onClick={() => navigate(`/courses/${course.id}`)}
              className="w-full text-left bg-gray-50 hover:bg-gray-100 transition-colors rounded-2xl p-4"
            >
              <p className="text-gray-800 text-base" style={{ fontWeight: 600 }}>
                {course.name}
              </p>
              <div className="flex items-center gap-4 mt-1 text-xs text-gray-500">
                <span>{course.year}</span>
                <span>·</span>
                <span>{course.studentCount} alumnos</span>
              </div>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}