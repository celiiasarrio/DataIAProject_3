import { ChevronLeft, BookOpen, Save } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useEffect, useMemo, useState } from 'react';
import {
  getBlockTasks,
  getMyBlocks,
  getTaskGrades,
  saveGrade,
  type BlockOut,
  type GradeRosterRow,
  type TaskOut,
} from '../api/client';
import { CenteredLoadingSpinner } from './ui/LoadingSpinner';

export function TeacherGradesScreen() {
  const navigate = useNavigate();
  const [blocks, setBlocks] = useState<BlockOut[]>([]);
  const [tasks, setTasks] = useState<TaskOut[]>([]);
  const [rows, setRows] = useState<GradeRosterRow[]>([]);
  const [blockId, setBlockId] = useState('');
  const [taskId, setTaskId] = useState('');
  const [grades, setGrades] = useState<Record<string, string>>({});
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState<string | null>(null);

  useEffect(() => {
    getMyBlocks()
      .then((data) => {
        setBlocks(data);
        if (data[0]) setBlockId(data[0].id_bloque);
      })
      .catch(() => setBlocks([]))
      .finally(() => setLoading(false));
  }, []);

  useEffect(() => {
    if (!blockId) return;
    setTasks([]);
    setRows([]);
    setTaskId('');
    getBlockTasks(blockId).then((data) => {
      setTasks(data);
      if (data[0]) setTaskId(String(data[0].id_tarea));
    });
  }, [blockId]);

  useEffect(() => {
    if (!taskId) return;
    getTaskGrades(Number(taskId)).then((data) => {
      setRows(data);
      setGrades(Object.fromEntries(data.map((row) => [row.id_alumno, row.nota?.toString() ?? ''])));
    });
  }, [taskId]);

  const selectedBlock = blocks.find((block) => block.id_bloque === blockId);
  const selectedTask = useMemo(
    () => tasks.find((task) => String(task.id_tarea) === taskId),
    [tasks, taskId],
  );

  const handleGradeChange = (studentId: string, value: string) => {
    if (value !== '') {
      const parsed = Number(value);
      if (Number.isNaN(parsed) || parsed < 0 || parsed > 10) return;
    }
    setGrades((prev) => ({ ...prev, [studentId]: value }));
  };

  const handleSave = async () => {
    if (!taskId) return;
    setSaving(true);
    setMessage(null);
    try {
      const changes = rows
        .map((row) => ({ row, raw: grades[row.id_alumno] }))
        .filter(({ raw }) => raw !== undefined && raw !== '')
        .map(({ row, raw }) => saveGrade(row.id_alumno, Number(taskId), Number(raw)));
      await Promise.all(changes);
      setRows(await getTaskGrades(Number(taskId)));
      setMessage('Notas guardadas');
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'No se han podido guardar las notas');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#008899] pb-20">
      <div className="px-5 pt-12 pb-6">
        <div className="flex items-center gap-3 mb-6">
          <button onClick={() => navigate(-1)} className="p-1">
            <ChevronLeft className="text-white" size={24} />
          </button>
          <div>
            <h1 className="text-white text-xl" style={{ fontWeight: 600 }}>Calificar Alumnos</h1>
            <p className="text-white text-xs opacity-80">{selectedBlock?.nombre ?? 'Bloques asignados'}</p>
          </div>
        </div>

        <div className="grid gap-2">
          <select
            value={blockId}
            onChange={(e) => setBlockId(e.target.value)}
            className="w-full rounded-xl bg-white/15 px-3 py-2 text-sm text-white focus:outline-none"
          >
            {blocks.map((block) => (
              <option key={block.id_bloque} value={block.id_bloque} className="text-black">
                {block.nombre}
              </option>
            ))}
          </select>
          <select
            value={taskId}
            onChange={(e) => setTaskId(e.target.value)}
            className="w-full rounded-xl bg-white/15 px-3 py-2 text-sm text-white focus:outline-none"
          >
            {tasks.map((task) => (
              <option key={task.id_tarea} value={task.id_tarea} className="text-black">
                {task.nombre}
              </option>
            ))}
          </select>
        </div>
      </div>

      <div className="bg-white rounded-t-3xl px-5 pt-5 pb-6 min-h-[70vh]">
        <div className="flex items-center gap-2 mb-5">
          <BookOpen size={18} className="text-[#008899]" />
          <h2 className="text-[#008899]" style={{ fontWeight: 700 }}>
            {selectedTask?.nombre ?? 'Selecciona una tarea'}
          </h2>
        </div>

        {loading ? (
          <CenteredLoadingSpinner />
        ) : rows.length === 0 ? (
          <p className="text-gray-400 text-sm text-center py-8">No hay alumnos para esta tarea.</p>
        ) : (
          <div className="space-y-3">
            {rows.map((student) => (
              <div key={student.id_alumno} className="bg-gray-50 rounded-2xl p-4 flex items-center justify-between gap-3">
                <div className="min-w-0">
                  <p className="text-gray-800 text-sm truncate" style={{ fontWeight: 600 }}>
                    {student.nombre} {student.apellido}
                  </p>
                  <p className="text-xs text-gray-400">{student.id_alumno}</p>
                </div>
                <input
                  type="number"
                  step="0.1"
                  min="0"
                  max="10"
                  value={grades[student.id_alumno] ?? ''}
                  onChange={(e) => handleGradeChange(student.id_alumno, e.target.value)}
                  placeholder="-"
                  className="w-20 text-center text-sm font-semibold bg-white border border-gray-300 rounded-md py-1 px-2 focus:outline-none focus:ring-2 focus:ring-[#008899]"
                />
              </div>
            ))}
          </div>
        )}

        {message && <p className="mt-4 text-center text-sm text-gray-500">{message}</p>}
        <button
          onClick={handleSave}
          disabled={!taskId || saving}
          className="w-full bg-[#008899] disabled:bg-gray-300 text-white py-3 rounded-xl mt-6 hover:bg-[#007788] transition-colors flex items-center justify-center gap-2"
        >
          <Save size={16} />
          {saving ? 'Guardando...' : 'Guardar Cambios'}
        </button>
      </div>
    </div>
  );
}
