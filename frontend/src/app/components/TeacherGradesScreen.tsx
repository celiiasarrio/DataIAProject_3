import { ChevronDown, ChevronLeft, ChevronUp, BookOpen, Save } from 'lucide-react';
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

const formatGrade = (value: number | null): string =>
  value == null
    ? ''
    : new Intl.NumberFormat('es-ES', { maximumFractionDigits: 2 }).format(value);

const parseGrade = (value: string): number => Number(value.replace(',', '.'));

const calculateAverage = (rows: GradeRosterRow[]): number | null => {
  const grades = rows.map(r => r.nota).filter((n): n is number => n != null);
  return grades.length > 0 ? grades.reduce((a, b) => a + b, 0) / grades.length : null;
};

const isGradableBlock = (blockName: string): boolean => {
  const nonGradable = ['PPTX', 'Hitos', 'TFM', 'Hackatón', 'Hackatones', 'Experiencia internacional', 'Soft Skills', 'Soft skills'];
  return !nonGradable.some(name => blockName.toLowerCase().includes(name.toLowerCase()));
};

export function TeacherGradesScreen() {
  const navigate = useNavigate();
  const [blocks, setBlocks] = useState<BlockOut[]>([]);
  const [tasks, setTasks] = useState<TaskOut[]>([]);
  const [rows, setRows] = useState<GradeRosterRow[]>([]);
  const [blockId, setBlockId] = useState('');
  const [taskId, setTaskId] = useState('');
  const [grades, setGrades] = useState<Record<string, string>>({});
  const [gradesOpen, setGradesOpen] = useState(false);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState<string | null>(null);

  useEffect(() => {
    getMyBlocks()
      .then(async (data) => {
        const gradableBlocks = data.filter(block => isGradableBlock(block.nombre));
        setBlocks(gradableBlocks);

        if (gradableBlocks.length === 0) {
          setLoading(false);
          return;
        }

        let nextTaskBlockId = gradableBlocks[0].id_bloque;
        let nextTaskId = '';

        try {
          const allTasks = await Promise.all(
            gradableBlocks.map(block => getBlockTasks(block.id_bloque))
          );

          const now = new Date();
          let closestTask: { blockId: string; taskId: number; fecha: string } | null = null;

          gradableBlocks.forEach((block, blockIndex) => {
            const blockTasks = allTasks[blockIndex];
            blockTasks.forEach(task => {
              if (!task.fecha) return;
              const taskDate = new Date(task.fecha);
              if (taskDate > now) {
                if (!closestTask || taskDate < new Date(closestTask.fecha)) {
                  closestTask = { blockId: block.id_bloque, taskId: task.id_tarea, fecha: task.fecha };
                }
              }
            });
          });

          if (closestTask) {
            nextTaskBlockId = closestTask.blockId;
            nextTaskId = String(closestTask.taskId);
          }
        } catch (error) {
          console.error('Error finding next task:', error);
        }

        setBlockId(nextTaskBlockId);
        if (nextTaskId) setTaskId(nextTaskId);
        setLoading(false);
      })
      .catch(() => {
        setBlocks([]);
        setLoading(false);
      });
  }, []);

  useEffect(() => {
    if (!blockId) return;
    setTasks([]);
    setRows([]);
    setTaskId('');
    setGradesOpen(false);
    getBlockTasks(blockId).then((data) => {
      setTasks(data);
      if (data[0]) setTaskId(String(data[0].id_tarea));
    });
  }, [blockId]);

  useEffect(() => {
    if (!taskId) return;
    setGradesOpen(false);
    getTaskGrades(Number(taskId)).then((data) => {
      setRows(data);
      setGrades(Object.fromEntries(data.map((row) => [row.id_alumno, formatGrade(row.nota)])));
    });
  }, [taskId]);

  const selectedBlock = blocks.find((block) => block.id_bloque === blockId);
  const selectedTask = useMemo(
    () => tasks.find((task) => String(task.id_tarea) === taskId),
    [tasks, taskId],
  );

  const handleGradeChange = (studentId: string, value: string) => {
    if (!/^\d{0,2}([,.]\d{0,2})?$/.test(value)) return;
    if (value !== '' && value !== ',' && value !== '.') {
      const parsed = parseGrade(value);
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
        .map(({ row, raw }) => saveGrade(row.id_alumno, Number(taskId), parseGrade(raw)));
      await Promise.all(changes);
      const updatedRows = await getTaskGrades(Number(taskId));
      setRows(updatedRows);
      setGrades(Object.fromEntries(updatedRows.map((row) => [row.id_alumno, formatGrade(row.nota)])));
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
          <>
            {(() => {
              const avg = calculateAverage(rows);
              return avg !== null ? (
                <div className="mb-5 flex justify-center">
                  <div className="flex flex-col items-center gap-2">
                    <div className="w-24 h-24 rounded-full bg-[#008899] flex items-center justify-center">
                      <span className="text-white text-3xl" style={{ fontWeight: 800 }}>
                        {formatGrade(avg)}
                      </span>
                    </div>
                    <p className="text-xs text-gray-500">Media del grupo</p>
                  </div>
                </div>
              ) : null;
            })()}
            <button
              onClick={() => setGradesOpen((open) => !open)}
              className="w-full bg-gray-50 rounded-2xl p-4 flex items-center justify-between text-left"
            >
              <div>
                <p className="text-gray-800 text-sm" style={{ fontWeight: 700 }}>Notas de alumnos</p>
                <p className="text-xs text-gray-400">{rows.length} alumnos</p>
              </div>
              {gradesOpen ? <ChevronUp size={18} className="text-gray-400" /> : <ChevronDown size={18} className="text-gray-400" />}
            </button>

            {gradesOpen && (
              <div className="space-y-3 mt-3">
                {rows.map((student) => (
                  <div key={student.id_alumno} className="bg-gray-50 rounded-2xl p-4 flex items-center justify-between gap-3">
                    <div className="min-w-0">
                      <p className="text-gray-800 text-sm truncate" style={{ fontWeight: 600 }}>
                        {student.nombre} {student.apellido}
                      </p>
                      <p className="text-xs text-gray-400">{student.id_alumno}</p>
                    </div>
                    <input
                      type="text"
                      inputMode="decimal"
                      value={grades[student.id_alumno] ?? ''}
                      onChange={(e) => handleGradeChange(student.id_alumno, e.target.value)}
                      placeholder="-"
                      className="w-20 text-center text-sm font-semibold bg-white border border-gray-300 rounded-md py-1 px-2 focus:outline-none focus:ring-2 focus:ring-[#008899]"
                    />
                  </div>
                ))}
              </div>
            )}
          </>
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
