import { ChevronLeft, CheckCircle2, Circle } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useEffect, useState } from 'react';
import { getCalendarEvents, getSessionAttendanceRoster, saveAttendance, type CalendarEvent, type AttendanceRosterRow } from '../api/client';
import { CenteredLoadingSpinner } from './ui/LoadingSpinner';

export function GroupAttendanceScreen() {
  const navigate = useNavigate();
  const [sessions, setSessions] = useState<CalendarEvent[]>([]);
  const [sessionId, setSessionId] = useState('');
  const [students, setStudents] = useState<AttendanceRosterRow[]>([]);
  const [attendance, setAttendance] = useState<Record<string, boolean>>({});
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState<string | null>(null);

  useEffect(() => {
    getCalendarEvents()
      .then((data) => {
        const classSessions = data.filter(ev => ev.tipo === 'class' && ev.id_sesion);
        setSessions(classSessions);

        const now = new Date();
        const nextSession = classSessions
          .filter(ev => new Date(ev.fecha_fin) > now)
          .sort((a, b) => new Date(a.fecha_inicio).getTime() - new Date(b.fecha_inicio).getTime())[0];

        if (nextSession?.id_sesion) {
          setSessionId(nextSession.id_sesion);
        } else if (classSessions[0]) {
          setSessionId(classSessions[0].id_sesion || '');
        }
      })
      .catch(() => setSessions([]))
      .finally(() => setLoading(false));
  }, []);

  useEffect(() => {
    if (!sessionId) return;
    setStudents([]);
    setAttendance({});
    getSessionAttendanceRoster(sessionId).then((data) => {
      setStudents(data);
      const attendanceMap: Record<string, boolean> = {};
      data.forEach(student => {
        attendanceMap[student.id_alumno] = student.presente || false;
      });
      setAttendance(attendanceMap);
    });
  }, [sessionId]);

  const handleToggleAttendance = (studentId: string) => {
    setAttendance(prev => ({
      ...prev,
      [studentId]: !prev[studentId]
    }));
  };

  const handleSave = async () => {
    setSaving(true);
    setMessage(null);
    try {
      const changes = students
        .map(student => ({ studentId: student.id_alumno, present: attendance[student.id_alumno] }))
        .map(({ studentId, present }) => saveAttendance(studentId, sessionId, present));
      await Promise.all(changes);
      setMessage('Asistencia guardada correctamente');
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Error al guardar la asistencia');
    } finally {
      setSaving(false);
    }
  };

  const presentCount = Object.values(attendance).filter(Boolean).length;
  const totalCount = students.length;
  const attendancePercentage = totalCount > 0 ? Math.round((presentCount / totalCount) * 100) : 0;

  const selectedSession = sessions.find(s => s.id_sesion === sessionId);

  return (
    <div className="min-h-screen bg-[#008899] pb-20">
      <div className="px-5 pt-12 pb-6">
        <div className="flex items-center gap-3 mb-6">
          <button onClick={() => navigate(-1)} className="p-1">
            <ChevronLeft className="text-white" size={24} />
          </button>
          <div>
            <h1 className="text-white text-xl" style={{ fontWeight: 600 }}>Asistencia de Sesión</h1>
            <p className="text-white text-xs opacity-80">{selectedSession?.titulo ?? 'Sesión'}</p>
          </div>
        </div>

        <select
          value={sessionId}
          onChange={(e) => setSessionId(e.target.value)}
          className="w-full rounded-xl bg-white/15 px-3 py-2 text-sm text-white focus:outline-none"
        >
          {sessions.map((session) => (
            <option key={session.id} value={session.id_sesion || ''} className="text-black">
              {session.titulo}
            </option>
          ))}
        </select>
      </div>

      <div className="bg-white rounded-t-3xl px-5 pt-5 pb-6 min-h-[70vh]">
        {loading ? (
          <CenteredLoadingSpinner />
        ) : students.length === 0 ? (
          <p className="text-gray-400 text-sm text-center py-8">No hay alumnos en este grupo.</p>
        ) : (
          <>
            {/* Attendance Indicator */}
            <div className="mb-6 flex justify-center">
              <div className="flex flex-col items-center gap-2">
                <div className="w-24 h-24 rounded-full bg-[#008899] flex items-center justify-center">
                  <span className="text-white text-3xl" style={{ fontWeight: 800 }}>
                    {attendancePercentage}%
                  </span>
                </div>
                <p className="text-xs text-gray-500">Asistencia promedio</p>
              </div>
            </div>

            {/* Summary Cards */}
            <div className="grid grid-cols-2 gap-3 mb-6">
              <div className="bg-green-50 rounded-xl p-3 text-center">
                <p className="text-green-600 text-lg" style={{ fontWeight: 700 }}>{presentCount}</p>
                <p className="text-xs text-green-600">Presentes</p>
              </div>
              <div className="bg-red-50 rounded-xl p-3 text-center">
                <p className="text-red-600 text-lg" style={{ fontWeight: 700 }}>{totalCount - presentCount}</p>
                <p className="text-xs text-red-600">Ausentes</p>
              </div>
            </div>

            {/* Student List */}
            <div className="space-y-2 mb-4">
              {students.map((student) => (
                <button
                  key={student.id_alumno}
                  onClick={() => handleToggleAttendance(student.id_alumno)}
                  className={`w-full rounded-xl p-4 flex items-center justify-between transition-colors ${
                    attendance[student.id_alumno]
                      ? 'bg-green-50 border border-green-200'
                      : 'bg-gray-50 border border-gray-200'
                  }`}
                >
                  <div className="text-left min-w-0">
                    <p className="text-gray-800 text-sm truncate" style={{ fontWeight: 600 }}>
                      {student.nombre} {student.apellido}
                    </p>
                    <p className="text-xs text-gray-400">{student.id_alumno}</p>
                  </div>
                  {attendance[student.id_alumno] ? (
                    <CheckCircle2 size={20} className="text-green-600 flex-shrink-0" />
                  ) : (
                    <Circle size={20} className="text-gray-400 flex-shrink-0" />
                  )}
                </button>
              ))}
            </div>

            {message && <p className="mt-4 text-center text-sm text-gray-500">{message}</p>}
            <button
              onClick={handleSave}
              disabled={saving}
              className="w-full bg-[#008899] disabled:bg-gray-300 text-white py-3 rounded-xl mt-6 hover:bg-[#007788] transition-colors"
              style={{ fontWeight: 600 }}
            >
              {saving ? 'Guardando...' : 'Guardar Asistencia'}
            </button>
          </>
        )}
      </div>
    </div>
  );
}
