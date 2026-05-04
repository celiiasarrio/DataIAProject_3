import { ChevronLeft, Save, Check } from 'lucide-react';
import { useNavigate, useParams } from 'react-router';
import { useEffect, useState } from 'react';
import {
  getSessionAttendanceRoster,
  saveAttendance,
  type AttendanceRosterRow,
} from '../api/client';

export function ClassAttendanceScreen() {
  const navigate = useNavigate();
  const { sessionId } = useParams<{ sessionId: string }>();
  const [students, setStudents] = useState<AttendanceRosterRow[]>([]);
  const [attendance, setAttendance] = useState<Record<string, boolean>>({});
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState<string | null>(null);

  useEffect(() => {
    if (!sessionId) return;
    setLoading(true);
    getSessionAttendanceRoster(sessionId)
      .then((data) => {
        setStudents(data);
        setAttendance(Object.fromEntries(data.map((row) => [row.id_alumno, row.presente === true])));
      })
      .catch(() => {
        setStudents([]);
        setAttendance({});
      })
      .finally(() => setLoading(false));
  }, [sessionId]);

  const handleAttendanceChange = (studentId: string) => {
    setAttendance((prev) => ({ ...prev, [studentId]: !prev[studentId] }));
  };

  const allPresent = students.length > 0 && students.every((student) => attendance[student.id_alumno]);

  const toggleAll = () => {
    setAttendance(Object.fromEntries(students.map((student) => [student.id_alumno, !allPresent])));
  };

  const handleSave = async () => {
    if (!sessionId) return;
    setSaving(true);
    setMessage(null);
    try {
      await Promise.all(
        students.map((student) =>
          saveAttendance(student.id_alumno, sessionId, attendance[student.id_alumno] === true, student.fecha),
        ),
      );
      setMessage('Asistencia guardada');
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'No se ha podido guardar la asistencia');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#008899] pb-20">
      <div className="px-5 pt-12 pb-6">
        <div className="flex items-center gap-3">
          <button onClick={() => navigate(-1)} className="p-1">
            <ChevronLeft className="text-white" size={24} />
          </button>
          <div>
            <h1 className="text-white text-xl" style={{ fontWeight: 600 }}>Pasar Asistencia</h1>
            <p className="text-white text-xs opacity-80">{sessionId ?? 'Sesión'}</p>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-t-3xl px-5 pt-5 pb-6 min-h-[70vh]">
        <div className="flex justify-end mb-4">
          <button onClick={toggleAll} className="text-sm text-[#008899]" style={{ fontWeight: 600 }}>
            {allPresent ? 'Desmarcar todos' : 'Marcar todos como presentes'}
          </button>
        </div>

        {loading ? (
          <p className="text-gray-400 text-sm text-center py-8">Cargando alumnos...</p>
        ) : students.length === 0 ? (
          <p className="text-gray-400 text-sm text-center py-8">No hay alumnos para esta sesión.</p>
        ) : (
          <div className="space-y-3 mb-6">
            {students.map((student) => {
              const present = attendance[student.id_alumno] === true;
              return (
                <button
                  key={student.id_alumno}
                  onClick={() => handleAttendanceChange(student.id_alumno)}
                  className={`w-full flex items-center justify-between gap-4 rounded-2xl p-4 transition-colors text-left ${present ? 'bg-green-50' : 'bg-gray-50'}`}
                >
                  <div className="min-w-0">
                    <p className={`transition-colors truncate ${present ? 'text-gray-800' : 'text-gray-500'}`}>
                      {student.nombre} {student.apellido}
                    </p>
                    <p className="text-xs text-gray-400">{student.id_alumno}</p>
                  </div>
                  <div className={`w-6 h-6 rounded-md flex items-center justify-center border-2 transition-all ${present ? 'bg-[#008899] border-[#008899]' : 'border-gray-300'}`}>
                    {present && <Check size={16} className="text-white" />}
                  </div>
                </button>
              );
            })}
          </div>
        )}

        {message && <p className="mb-4 text-center text-sm text-gray-500">{message}</p>}
        <button
          onClick={handleSave}
          disabled={!sessionId || saving || students.length === 0}
          className="w-full bg-[#008899] disabled:bg-gray-300 text-white py-3 rounded-lg flex items-center justify-center gap-2 hover:bg-[#007788] transition-colors"
        >
          <Save size={16} />
          {saving ? 'Guardando...' : 'Guardar Asistencia'}
        </button>
      </div>
    </div>
  );
}
