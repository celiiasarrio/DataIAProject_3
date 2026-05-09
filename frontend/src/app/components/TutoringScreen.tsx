import { ChevronLeft, Check, X, RotateCcw, ChevronDown, Search } from 'lucide-react';
import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router';
import {
  createReservation,
  getProfessors,
  getReservations,
  getTutoringSlots,
  updateReservation,
  type ProfessorOut,
  type ReservationOut,
  type TutoringSlot,
} from '../api/client';
import { CenteredLoadingSpinner } from './ui/LoadingSpinner';

const DAYS = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];

const TIME_SLOTS = Array.from({ length: 20 }, (_, i) => {
  const mins = 8 * 60 + i * 30;
  return `${String(Math.floor(mins / 60)).padStart(2, '0')}:${String(mins % 60).padStart(2, '0')}`;
});

const todayStr = () => {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
};

const statusLabel: Record<string, string> = {
  pending: 'Pendiente',
  approved: 'Aprobada',
  rejected: 'Rechazada',
  alternative: 'Propuesta alternativa',
  cancelled: 'Cancelada',
};

const statusClass: Record<string, string> = {
  pending: 'bg-amber-100 text-amber-700',
  approved: 'bg-green-100 text-green-700',
  rejected: 'bg-red-100 text-red-700',
  alternative: 'bg-blue-100 text-blue-700',
  cancelled: 'bg-gray-100 text-gray-600',
};

const toDateKey = (date: Date) =>
  `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;

const nextDatesForWeekday = (weekday: number) => {
  const today = new Date();
  return Array.from({ length: 5 }, (_, index) => {
    const date = new Date(today);
    const diff = (weekday - ((today.getDay() + 6) % 7) + 7) % 7;
    date.setDate(today.getDate() + diff + index * 7);
    return toDateKey(date);
  });
};

const formatDate = (value: string) =>
  new Intl.DateTimeFormat('es-ES', { weekday: 'short', day: '2-digit', month: 'short' }).format(new Date(value));

const professorName = (professors: ProfessorOut[], id: string) => {
  const professor = professors.find((item) => item.id_profesor === id);
  return professor ? `${professor.nombre} ${professor.apellido}` : id;
};

const slotLabel = (slot?: TutoringSlot) =>
  slot ? `${DAYS[slot.dia_semana]} · ${slot.hora_inicio.slice(0, 5)}-${slot.hora_fin.slice(0, 5)} · ${slot.ubicacion}` : 'Franja no disponible';

export function TutoringScreen() {
  const navigate = useNavigate();
  const [role] = useState(() => localStorage.getItem('userRole') || 'student');
  const [professors, setProfessors] = useState<ProfessorOut[]>([]);
  const [slots, setSlots] = useState<TutoringSlot[]>([]);
  const [reservations, setReservations] = useState<ReservationOut[]>([]);
  const [professorId, setProfessorId] = useState('');
  const [professorSearch, setProfessorSearch] = useState('');
  const [professorOpen, setProfessorOpen] = useState(false);
  const [date, setDate] = useState('');
  const [time, setTime] = useState('');
  const [notes, setNotes] = useState('');
  const [responseNotes, setResponseNotes] = useState<Record<string, string>>({});
  const [alternativeSlot, setAlternativeSlot] = useState<Record<string, string>>({});
  const [alternativeDate, setAlternativeDate] = useState<Record<string, string>>({});
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState<string | null>(null);

  const isStudent = role === 'student';

  useEffect(() => {
    Promise.allSettled([getProfessors(), getTutoringSlots(), getReservations()])
      .then(([professorRes, slotRes, reservationRes]) => {
        const professorData = professorRes.status === 'fulfilled' ? professorRes.value : [];
        const slotData = slotRes.status === 'fulfilled' ? slotRes.value : [];
        const reservationData = reservationRes.status === 'fulfilled' ? reservationRes.value : [];
        setProfessors(professorData);
        setSlots(slotData.filter((slot) => slot.disponible));
        setReservations(reservationData);
        const firstProfessor = professorData[0]?.id_profesor ?? '';
        setProfessorId(firstProfessor);
      })
      .finally(() => setLoading(false));
  }, []);

  const filteredProfessors = useMemo(() => {
    const query = professorSearch.trim().toLowerCase();
    if (!query) return professors;
    return professors.filter((p) =>
      `${p.nombre} ${p.apellido}`.toLowerCase().includes(query),
    );
  }, [professors, professorSearch]);

  const selectedProfessor = professors.find((p) => p.id_profesor === professorId);
  const canRequest = !!professorId && !!date && !!time && notes.trim().length > 0 && !saving;

  const reservationSlot = (reservation: ReservationOut) => slots.find((slot) => slot.id === reservation.id_franja);

  const submitRequest = async () => {
    if (!professorId || !date || !time) {
      setMessage('Selecciona profesor, fecha y hora.');
      return;
    }
    setSaving(true);
    setMessage(null);
    try {
      const created = await createReservation({
        id_profesor: professorId,
        hora: time,
        fecha: date,
        notas: notes.trim() || null,
      });
      setReservations((current) => [created, ...current]);
      setNotes('');
      setDate('');
      setTime('');
      setMessage('Solicitud enviada');
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'No se ha podido solicitar la tutoría');
    } finally {
      setSaving(false);
    }
  };

  const respond = async (
    reservation: ReservationOut,
    estado: string,
    alternative?: { id_franja: string; fecha: string },
  ) => {
    setSaving(true);
    setMessage(null);
    try {
      const payload =
        estado === 'alternative'
          ? {
              estado,
              id_franja: alternative?.id_franja ?? alternativeSlot[reservation.id],
              fecha: alternative?.fecha ?? alternativeDate[reservation.id],
              notas: responseNotes[reservation.id] || reservation.notas,
            }
          : { estado, notas: responseNotes[reservation.id] || reservation.notas };
      const updated = await updateReservation(reservation.id, payload);
      setReservations((current) => current.map((item) => (item.id === updated.id ? updated : item)));
      setMessage('Tutoría actualizada');
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'No se ha podido actualizar la tutoría');
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
            <h1 className="text-white text-xl" style={{ fontWeight: 600 }}>Tutorías</h1>
            <p className="text-white text-xs opacity-80">{isStudent ? 'Solicitudes y disponibilidad' : 'Solicitudes recibidas'}</p>
          </div>
        </div>
      </div>

      <div className="bg-white dark:bg-gray-900 rounded-t-3xl px-5 pt-5 pb-6 min-h-[70vh]">
        {loading ? (
          <CenteredLoadingSpinner />
        ) : (
          <>
            {isStudent && (
              <div className="bg-gray-50 dark:bg-gray-800 rounded-2xl p-4 mb-5 space-y-3">
                <h2 className="text-[#008899] dark:text-cyan-300 text-sm" style={{ fontWeight: 800 }}>Solicitar tutoría</h2>

                <div className="space-y-1">
                  <label className="text-xs text-gray-500 dark:text-gray-400" style={{ fontWeight: 600 }}>Profesor</label>
                  <div className="relative">
                    <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 pointer-events-none" />
                    <input
                      type="text"
                      placeholder="Buscar profesor..."
                      value={professorOpen ? professorSearch : selectedProfessor ? `${selectedProfessor.nombre} ${selectedProfessor.apellido}` : ''}
                      onFocus={() => {
                        setProfessorOpen(true);
                        setProfessorSearch('');
                      }}
                      onClick={() => setProfessorOpen(true)}
                      onBlur={() => window.setTimeout(() => setProfessorOpen(false), 150)}
                      onChange={(event) => setProfessorSearch(event.target.value)}
                      className="w-full rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 text-gray-900 dark:text-gray-100 placeholder:text-gray-400 dark:placeholder:text-gray-500 pl-9 pr-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#008899]/40 focus:border-[#008899]"
                    />
                    {professorOpen && (
                      <ul className="absolute z-20 left-0 right-0 mt-1 max-h-52 overflow-auto rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 shadow-lg">
                        {filteredProfessors.length === 0 ? (
                          <li className="px-3 py-2 text-sm text-gray-400">
                            {professors.length === 0 ? 'No hay profesores cargados' : 'Sin coincidencias'}
                          </li>
                        ) : (
                          filteredProfessors.map((p) => {
                            const isSel = p.id_profesor === professorId;
                            return (
                              <li
                                key={p.id_profesor}
                                onMouseDown={(event) => {
                                  event.preventDefault();
                                  setProfessorId(p.id_profesor);
                                  setProfessorOpen(false);
                                  setProfessorSearch('');
                                }}
                                className={`px-3 py-2 text-sm cursor-pointer ${isSel ? 'bg-[#008899]/10 text-[#008899] dark:text-cyan-300' : 'hover:bg-gray-100 dark:hover:bg-gray-800 text-gray-800 dark:text-gray-100'}`}
                                style={{ fontWeight: isSel ? 700 : 500 }}
                              >
                                {p.nombre} {p.apellido}
                              </li>
                            );
                          })
                        )}
                      </ul>
                    )}
                  </div>
                </div>

                <div className="space-y-1">
                  <label className="text-xs text-gray-500 dark:text-gray-400" style={{ fontWeight: 600 }}>Fecha</label>
                  <input
                    type="date"
                    value={date}
                    min={todayStr()}
                    onChange={(event) => setDate(event.target.value)}
                    className="w-full rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 px-3 py-2 text-sm text-gray-800 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-[#008899]/40 focus:border-[#008899]"
                  />
                </div>

                <div className="space-y-1">
                  <label className="text-xs text-gray-500 dark:text-gray-400" style={{ fontWeight: 600 }}>Hora</label>
                  <div className="relative">
                    <select
                      value={time}
                      onChange={(event) => setTime(event.target.value)}
                      disabled={!date}
                      className="w-full appearance-none rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 pl-3 pr-10 py-2 text-sm text-gray-800 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-[#008899]/40 focus:border-[#008899] disabled:bg-gray-100 disabled:text-gray-400 dark:disabled:bg-gray-800 dark:disabled:text-gray-500"
                    >
                      <option value="">Selecciona una hora</option>
                      {TIME_SLOTS.map((t) => (
                        <option key={t} value={t}>{t}</option>
                      ))}
                    </select>
                    <ChevronDown size={16} className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 pointer-events-none" />
                  </div>
                </div>

                <div className="space-y-1">
                  <label className="text-xs text-gray-500 dark:text-gray-400" style={{ fontWeight: 600 }}>Motivo de la tutoría</label>
                  <textarea
                    value={notes}
                    onChange={(event) => setNotes(event.target.value)}
                    rows={3}
                    placeholder="Cuéntale al profesor en qué necesitas ayuda"
                    className="w-full rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 text-gray-900 dark:text-gray-100 placeholder:text-gray-400 dark:placeholder:text-gray-500 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#008899]/40 focus:border-[#008899]"
                  />
                </div>

                <button
                  onClick={submitRequest}
                  disabled={!canRequest}
                  className={`w-full py-3 rounded-xl text-sm transition-all duration-200 ${
                    canRequest
                      ? 'bg-[#008899] text-white shadow-lg shadow-[#008899]/40 ring-2 ring-[#008899]/30 hover:bg-[#007788]'
                      : 'bg-gray-200 text-gray-400 cursor-not-allowed'
                  }`}
                  style={{ fontWeight: 700 }}
                >
                  Solicitar cita
                </button>
              </div>
            )}

            {message && <p className="mb-4 text-center text-sm text-gray-500 dark:text-gray-400">{message}</p>}

            <div className="space-y-3">
              {reservations.length === 0 ? (
                <p className="text-gray-400 dark:text-gray-500 text-sm text-center py-8">No hay solicitudes de tutoría.</p>
              ) : (
                reservations.map((reservation) => {
                  const slot = reservationSlot(reservation);
                  const altSlots = slots.filter((item) => item.id_profesor === reservation.id_profesor);
                  const selectedAltSlot = slots.find((item) => item.id === alternativeSlot[reservation.id]) ?? altSlots[0];
                  const altDates = selectedAltSlot ? nextDatesForWeekday(selectedAltSlot.dia_semana) : [];
                  return (
                    <div key={reservation.id} className="bg-gray-50 dark:bg-gray-800 rounded-2xl p-4">
                      <div className="flex items-start justify-between gap-3">
                        <div>
                          <p className="text-gray-800 dark:text-gray-100 text-sm" style={{ fontWeight: 700 }}>{professorName(professors, reservation.id_profesor)}</p>
                          <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">
                            {formatDate(reservation.fecha)} · {reservation.hora ? reservation.hora.slice(0, 5) : slotLabel(slot)}
                          </p>
                        </div>
                        <span className={`text-xs px-2 py-1 rounded-full ${statusClass[reservation.estado] ?? statusClass.pending}`}>
                          {statusLabel[reservation.estado] ?? reservation.estado}
                        </span>
                      </div>
                      {reservation.notas && <p className="text-sm text-gray-600 dark:text-gray-300 mt-3">{reservation.notas}</p>}

                      {isStudent && reservation.estado === 'pending' && (
                        <button onClick={() => respond(reservation, 'cancelled')} disabled={saving} className="mt-3 text-sm text-red-600" style={{ fontWeight: 700 }}>
                          Cancelar solicitud
                        </button>
                      )}
                      {isStudent && reservation.estado === 'alternative' && (
                        <div className="grid grid-cols-2 gap-2 mt-3">
                          <button onClick={() => respond(reservation, 'approved')} disabled={saving} className="bg-[#008899] text-white py-2 rounded-lg text-sm">Aceptar</button>
                          <button onClick={() => respond(reservation, 'rejected')} disabled={saving} className="bg-red-50 text-red-600 py-2 rounded-lg text-sm">Rechazar</button>
                        </div>
                      )}

                      {!isStudent && (
                        <div className="mt-4 space-y-2">
                          <textarea
                            value={responseNotes[reservation.id] ?? ''}
                            onChange={(event) => setResponseNotes((current) => ({ ...current, [reservation.id]: event.target.value }))}
                            rows={2}
                            placeholder="Comentario opcional"
                            className="w-full rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm"
                          />
                          <div className="grid grid-cols-3 gap-2">
                            <button onClick={() => respond(reservation, 'approved')} disabled={saving} className="bg-green-50 text-green-700 py-2 rounded-lg text-sm flex items-center justify-center gap-1"><Check size={14} /> Aprobar</button>
                            <button onClick={() => respond(reservation, 'rejected')} disabled={saving} className="bg-red-50 text-red-600 py-2 rounded-lg text-sm flex items-center justify-center gap-1"><X size={14} /> Rechazar</button>
                            <button
                              onClick={() => {
                                const fallbackSlot = alternativeSlot[reservation.id] || altSlots[0]?.id || '';
                                const slotForDate = slots.find((item) => item.id === fallbackSlot) ?? selectedAltSlot;
                                const fallbackDate = alternativeDate[reservation.id] || (slotForDate ? nextDatesForWeekday(slotForDate.dia_semana)[0] : '');
                                setAlternativeSlot((current) => ({ ...current, [reservation.id]: fallbackSlot }));
                                setAlternativeDate((current) => ({ ...current, [reservation.id]: fallbackDate }));
                                respond(reservation, 'alternative', { id_franja: fallbackSlot, fecha: fallbackDate });
                              }}
                              disabled={saving}
                              className="bg-blue-50 text-blue-700 py-2 rounded-lg text-sm flex items-center justify-center gap-1"
                            >
                              <RotateCcw size={14} /> Proponer
                            </button>
                          </div>
                          <div className="grid grid-cols-2 gap-2">
                            <select
                              value={alternativeSlot[reservation.id] ?? altSlots[0]?.id ?? ''}
                              onChange={(event) => setAlternativeSlot((current) => ({ ...current, [reservation.id]: event.target.value }))}
                              className="rounded-lg border border-gray-200 bg-white px-3 py-2 text-xs"
                            >
                              {altSlots.map((item) => <option key={item.id} value={item.id}>{slotLabel(item)}</option>)}
                            </select>
                            <select
                              value={alternativeDate[reservation.id] ?? altDates[0] ?? ''}
                              onChange={(event) => setAlternativeDate((current) => ({ ...current, [reservation.id]: event.target.value }))}
                              className="rounded-lg border border-gray-200 bg-white px-3 py-2 text-xs"
                            >
                              {altDates.map((item) => <option key={item} value={item}>{formatDate(item)}</option>)}
                            </select>
                          </div>
                        </div>
                      )}
                    </div>
                  );
                })
              )}
            </div>
          </>
        )}
      </div>
    </div>
  );
}
