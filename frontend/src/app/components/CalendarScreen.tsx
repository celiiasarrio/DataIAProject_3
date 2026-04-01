import { useState, useEffect } from 'react';
import { ChevronLeft, BookOpen, FileText, AlertCircle, Plus, X } from 'lucide-react';
import { useNavigate } from 'react-router';

type ViewMode = 'semana' | 'jus' | 'dia' | 'mes';
type EventType = 'clase' | 'entrega' | 'examen';

interface CalEvent {
  id: number;
  subjectCode: string;
  type: EventType;
  subject: string;
  day: number; // 0=LUN, 1=MAR, 2=MIÉ, 3=JUE, 4=VIE, 5=SÁB
  startHour: number;
  endHour: number;
}

const HOUR_HEIGHT = 56;
const START_HOUR = 8;

const EVENT_STYLES: Record<EventType, { bg: string; text: string; dot: string; border: string }> = {
  clase:   { bg: 'bg-blue-500',  text: 'text-white', dot: 'bg-blue-500',  border: 'border-blue-600' },
  entrega: { bg: 'bg-amber-400', text: 'text-white', dot: 'bg-amber-400', border: 'border-amber-500' },
  examen:  { bg: 'bg-red-500',   text: 'text-white', dot: 'bg-red-500',   border: 'border-red-600'  },
};

const weekDays = [
  { short: 'LUN', date: 23, label: 'Lunes 23' },
  { short: 'MAR', date: 24, label: 'Martes 24' },
  { short: 'MIÉ', date: 25, label: 'Miércoles 25' },
  { short: 'JUE', date: 26, label: 'Jueves 26' },
  { short: 'VIE', date: 27, label: 'Viernes 27' },
  { short: 'SÁB', date: 28, label: 'Sábado 28' },
];

const allEvents: CalEvent[] = [
  // Lunes 23
  { id: 1,  type: 'clase',   subject: 'Big Data & Analytics', subjectCode: 'bda-301', day: 0, startHour: 10,   endHour: 12   },
  { id: 2,  type: 'clase',   subject: 'Análisis de Datos',    subjectCode: 'ada-303', day: 0, startHour: 16,   endHour: 18   },
  // Martes 24
  { id: 3,  type: 'clase',   subject: 'Marketing Digital',    subjectCode: 'mkt-201', day: 1, startHour: 9,    endHour: 11   },
  { id: 4,  type: 'clase',   subject: 'Finanzas Corporativas',subjectCode: 'fin-302', day: 1, startHour: 14,   endHour: 16   },
  // Miércoles 25 (hoy)
  { id: 5,  type: 'clase',   subject: 'Estrategia Empresarial',subjectCode: 'est-401', day: 2, startHour: 10,   endHour: 12   },
  { id: 6,  type: 'entrega', subject: 'Entrega: Proy. Big Data', subjectCode: 'bda-301', day: 2, startHour: 13, endHour: 13.5 },
  // Jueves 26
  { id: 7,  type: 'clase',   subject: 'Big Data & Analytics', subjectCode: 'bda-301', day: 3, startHour: 9,    endHour: 11   },
  { id: 8,  type: 'examen',  subject: 'Examen Finanzas',      subjectCode: 'fin-302', day: 3, startHour: 12,   endHour: 14   },
  { id: 9,  type: 'clase',   subject: 'Coaching & Liderazgo', subjectCode: 'coa-201', day: 3, startHour: 16,   endHour: 18   },
  // Viernes 27
  { id: 10, type: 'clase',   subject: 'Marketing Digital',    subjectCode: 'mkt-201', day: 4, startHour: 10,   endHour: 12   },
  { id: 11, type: 'entrega', subject: 'Entrega: Informe Mkt', subjectCode: 'mkt-201', day: 4, startHour: 13,   endHour: 13.5 },
  // Sábado 28
  { id: 12, type: 'clase',   subject: 'Finanzas Corporativas',subjectCode: 'fin-302', day: 5, startHour: 10,   endHour: 12   },
];

// March 2026: March 1 = Sunday → Monday-first grid: 6 leading nulls
const marchDays: (number | null)[] = [
  null, null, null, null, null, null, 1,
  2,  3,  4,  5,  6,  7,  8,
  9,  10, 11, 12, 13, 14, 15,
  16, 17, 18, 19, 20, 21, 22,
  23, 24, 25, 26, 27, 28, 29,
  30, 31, null, null, null, null, null,
];

const monthEventMap: Record<number, EventType[]> = {
  2:  ['clase'],
  3:  ['clase'],
  4:  ['clase'],
  5:  ['clase', 'examen'],
  6:  ['clase'],
  7:  ['clase'],
  9:  ['clase'],
  10: ['clase'],
  11: ['clase', 'entrega'],
  12: ['clase', 'examen'],
  13: ['clase'],
  14: ['clase'],
  16: ['clase'],
  17: ['clase'],
  18: ['clase'],
  19: ['clase'],
  20: ['clase', 'examen'],
  21: ['clase'],
  23: ['clase'],
  24: ['clase'],
  25: ['clase', 'entrega'],
  26: ['clase', 'examen'],
  27: ['clase', 'entrega'],
  28: ['clase'],
  30: ['clase'],
  31: ['clase'],
};

const formatHour = (h: number): string => {
  const hrs = Math.floor(h);
  const mins = String(Math.round((h - hrs) * 60)).padStart(2, '0');
  return `${hrs}:${mins}`;
};

const VIEW_BUTTONS: { mode: ViewMode; label: string }[] = [
  { mode: 'semana', label: 'L - V' },
  { mode: 'jus',    label: 'J - S' },
  { mode: 'dia',    label: 'Día'   },
  { mode: 'mes',    label: 'Mes'   },
];

const EVENT_ICONS: Record<EventType, React.ElementType> = {
  clase:   BookOpen,
  entrega: FileText,
  examen:  AlertCircle,
};

export function CalendarScreen() {
  const navigate = useNavigate();
  const [viewMode, setViewMode] = useState<ViewMode>('semana');
  const [selectedDayIdx, setSelectedDayIdx] = useState(2); // MIÉ 25 (hoy)
  const [userRole, setUserRole] = useState<string | null>(null);

  const [events, setEvents] = useState<CalEvent[]>(allEvents);
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [newEvent, setNewEvent] = useState<Partial<CalEvent>>({ type: 'examen', subject: '', day: 2, startHour: 10, endHour: 12 });
  const [selectedEvent, setSelectedEvent] = useState<CalEvent | null>(null);

  useEffect(() => {
    setUserRole(localStorage.getItem('userRole'));
  }, []);

  const isProfessor = userRole === 'professor';
  const isStudent = userRole === 'student';

  const hours = Array.from({ length: 12 }, (_, i) => i + START_HOUR); // 8–19

  const isCoordinator = userRole === 'admin';

  // Which days to display in time-grid views
  const getDisplayDays = () => {
    if (viewMode === 'semana') return weekDays.slice(0, 5);
    if (viewMode === 'jus')    return weekDays.slice(3, 6);
    if (viewMode === 'dia')    return [weekDays[selectedDayIdx]];
    return [];
  };

  // Which events to show
  const getDisplayEvents = (): CalEvent[] => {
    if (viewMode === 'semana') return events.filter(e => e.day <= 4);
    if (viewMode === 'jus')    return events.filter(e => e.day >= 3);
    if (viewMode === 'dia')    return events.filter(e => e.day === selectedDayIdx);
    return [];
  };

  // Map event.day → display column index
  const getDisplayColIndex = (event: CalEvent): number => {
    if (viewMode === 'semana') return event.day;
    if (viewMode === 'jus')    return event.day - 3;
    return 0;
  };

  const displayDays   = getDisplayDays();
  const displayEvents = getDisplayEvents();
  const totalCols     = displayDays.length;

  const gridTitle = () => {
    if (viewMode === 'mes')    return 'MARZO 2026';
    if (viewMode === 'dia')    return weekDays[selectedDayIdx].label.toUpperCase() + ' · MAR 2026';
    if (viewMode === 'semana') return 'SEMANA 23–27 MAR 2026';
    return 'JUE–SÁB 26–28 MAR 2026';
  };

  return (
    <div className="min-h-screen bg-[#008899] pb-20 flex flex-col">
      {/* ── Header ── */}
      <div className="px-5 pt-12 pb-4 flex-shrink-0">
        <div className="flex items-center gap-3 mb-4">
          <button onClick={() => navigate(-1)} className="p-1">
            <ChevronLeft className="text-white" size={24} />
          </button>
          <div>
            <h1 className="text-white text-xl" style={{ fontWeight: 300, fontFamily: 'Didot, Bodoni, serif' }}>EDEM</h1>
            <p className="text-white text-xs opacity-80">EDEM STUDENT HUB</p>
          </div>
        </div>

        {/* View mode toggle */}
        <div className="flex gap-1.5 mb-3">
          {VIEW_BUTTONS.map(({ mode, label }) => (
            <button
              key={mode}
              onClick={() => setViewMode(mode)}
              className={`flex-1 py-2 rounded-xl text-sm transition-all ${
                viewMode === mode
                  ? 'bg-white text-[#008899]'
                  : 'bg-white/20 text-white'
              }`}
              style={{ fontWeight: viewMode === mode ? 700 : 400 }}
            >
              {label}
            </button>
          ))}
        </div>

        {/* Legend */}
        <div className="flex gap-5">
          {(['clase', 'entrega', 'examen'] as EventType[]).map(type => {
            const Icon = EVENT_ICONS[type];
            return (
              <div key={type} className="flex items-center gap-1.5">
                <div className={`w-2 h-2 rounded-full ${EVENT_STYLES[type].dot}`} />
                <span className="text-white text-xs opacity-80 capitalize">{type}</span>
              </div>
            );
          })}
        </div>
      </div>

      {/* ── Calendar Body ── */}
      <div className="bg-white rounded-t-3xl flex-1 overflow-hidden flex flex-col">
        {/* Title row */}
        <div className="px-4 pt-4 pb-2 flex-shrink-0">
          <p className="text-[#008899] text-sm" style={{ fontWeight: 700 }}>{gridTitle()}</p>
        </div>

        {/* ── MONTHLY VIEW ── */}
        {viewMode === 'mes' && (
          <div className="px-4 pb-4">
            <div className="grid grid-cols-7 mb-1">
              {['L', 'M', 'X', 'J', 'V', 'S', 'D'].map((d, i) => (
                <div key={i} className="text-center text-xs text-gray-400 py-1">{d}</div>
              ))}
            </div>
            <div className="grid grid-cols-7 gap-y-1">
              {marchDays.map((day, i) => (
                <div key={i} className="flex flex-col items-center py-0.5">
                  {day !== null ? (
                    <>
                      <div
                        className={`w-7 h-7 flex items-center justify-center rounded-full text-xs ${
                          day === 25
                            ? 'bg-[#008899] text-white'
                            : 'text-gray-800'
                        }`}
                        style={{ fontWeight: day === 25 ? 700 : 400 }}
                      >
                        {day}
                      </div>
                      <div className="flex gap-0.5 mt-0.5">
                        {(monthEventMap[day] ?? []).map((type, j) => (
                          <div
                            key={j}
                            className={`w-1.5 h-1.5 rounded-full ${EVENT_STYLES[type].dot}`}
                          />
                        ))}
                      </div>
                    </>
                  ) : (
                    <div className="w-7 h-7" />
                  )}
                </div>
              ))}
            </div>

            {/* Event list for the month */}
            <div className="mt-5 space-y-2">
              <p className="text-xs text-gray-500 mb-2" style={{ fontWeight: 600 }}>PRÓXIMAS FECHAS CLAVE</p>
              {[
                { date: '25 Mar', type: 'entrega' as EventType, text: 'Entrega Proyecto Big Data' },
                { date: '26 Mar', type: 'examen'  as EventType, text: 'Examen Finanzas' },
                { date: '27 Mar', type: 'entrega' as EventType, text: 'Entrega Informe Marketing' },
                { date: '5 Abr',  type: 'examen'  as EventType, text: 'Examen Marketing Digital' },
                { date: '12 Abr', type: 'entrega' as EventType, text: 'Entrega Análisis de Datos' },
              ].map((item, i) => {
                const Icon = EVENT_ICONS[item.type];
                return (
                  <div
                    key={i}
                    onClick={() => isStudent && setSelectedEvent({ id: 999+i, subjectCode: '', type: item.type, subject: item.text, day: -1, startHour: 0, endHour: 0 })}
                    className={`flex items-center gap-3 bg-gray-50 rounded-xl px-3 py-2 ${isStudent ? 'cursor-pointer hover:bg-gray-100 transition-colors' : ''}`}
                  >
                    <div className={`p-1.5 rounded-lg ${EVENT_STYLES[item.type].bg}`}>
                      <Icon size={14} className="text-white" />
                    </div>
                    <div className="flex-1">
                      <p className="text-gray-800 text-sm" style={{ fontWeight: 500 }}>{item.text}</p>
                    </div>
                    <span className="text-xs text-gray-400">{item.date}</span>
                  </div>
                );
              })}
            </div>
          </div>
        )}
        {/* ── DAY SELECTOR (only for "Día" mode) ── */}
        {viewMode === 'dia' && (
          <div className="px-4 flex-shrink-0">
            <div className="flex gap-2 overflow-x-auto pb-2 no-scrollbar">
              {weekDays.map((day, i) => (
                <button
                  key={i}
                  onClick={() => setSelectedDayIdx(i)}
                  className={`flex-shrink-0 flex flex-col items-center px-3 py-1.5 rounded-xl transition-all ${
                    selectedDayIdx === i
                      ? 'bg-[#008899] text-white'
                      : 'bg-gray-100 text-gray-600'
                  }`}
                >
                  <span className="text-xs">{day.short}</span>
                  <span className="text-sm" style={{ fontWeight: 700 }}>{day.date}</span>
                </button>
              ))}
            </div>
          </div>
        )}
        {/* ── TIME GRID (semana, jus, dia) ── */}
        {viewMode !== 'mes' && (
          <div className="flex flex-col flex-1 overflow-hidden">
            {/* Day headers */}
            {viewMode !== 'dia' && (
              <div
                className="flex flex-shrink-0 border-b border-gray-100 px-4 py-2"
                style={{ paddingLeft: '3.5rem' }}
              >
                {displayDays.map((day, i) => (
                  <div
                    key={i}
                    className="text-center"
                    style={{ width: `${100 / totalCols}%` }}
                  >
                    <p className="text-xs text-gray-400">{day.short}</p>
                    <div
                      className={`w-7 h-7 mx-auto flex items-center justify-center rounded-full text-sm ${
                        day.date === 25
                          ? 'bg-[#008899] text-white'
                          : 'text-gray-700'
                      }`}
                      style={{ fontWeight: day.date === 25 ? 700 : 400 }}
                    >
                      {day.date}
                    </div>
                  </div>
                ))}
              </div>
            )}

            {/* Scrollable grid */}
            <div className="overflow-y-auto flex-1">
              <div className="flex px-2 pb-4">
                {/* Hours column */}
                <div className="flex-shrink-0" style={{ width: '3rem' }}>
                  {hours.map((h, i) => (
                    <div
                      key={i}
                      className="flex items-start justify-end pr-2 pt-0.5"
                      style={{ height: `${HOUR_HEIGHT}px` }}
                    >
                      <span className="text-xs text-gray-400">{`${h}:00`}</span>
                    </div>
                  ))}
                </div>

                {/* Events area */}
                <div
                  className="flex-1 relative"
                  style={{ height: `${hours.length * HOUR_HEIGHT}px` }}
                >
                  {/* Background: hour lines */}
                  {hours.map((_, i) => (
                    <div
                      key={i}
                      className="absolute w-full border-t border-gray-100"
                      style={{ top: `${i * HOUR_HEIGHT}px` }}
                    />
                  ))}

                  {/* Background: column separators */}
                  {displayDays.map((_, i) => i > 0 && (
                    <div
                      key={i}
                      className="absolute top-0 bottom-0 border-l border-gray-100"
                      style={{ left: `${(i / totalCols) * 100}%` }}
                    />
                  ))}

                  {/* Events */}
                  {displayEvents.map(event => {
                    const colIdx  = getDisplayColIndex(event);
                    const colW    = 100 / totalCols;
                    const top     = (event.startHour - START_HOUR) * HOUR_HEIGHT;
                    const height  = Math.max((event.endHour - event.startHour) * HOUR_HEIGHT - 3, 22);
                    const Icon    = EVENT_ICONS[event.type];
                    const styles  = EVENT_STYLES[event.type];
                    const isClickableForCoordinator = isCoordinator && event.type === 'clase';

                    const EventComponent = isClickableForCoordinator ? 'button' : 'div';

                    return (
                      <EventComponent
                        key={event.id}
                        onClick={() => {
                          if (isClickableForCoordinator) {
                            navigate(`/class/${event.subjectCode}/attendance`);
                          } else if (isStudent) {
                            setSelectedEvent(event);
                          }
                        }}
                        className={`absolute rounded-lg px-1.5 py-1 overflow-hidden shadow-sm text-left ${styles.bg} ${styles.text} ${
                          (isClickableForCoordinator || isStudent) ? 'cursor-pointer hover:opacity-90 transition-opacity' : ''}`}
                        style={{
                          top:    `${top + 1}px`,
                          left:   `calc(${colIdx * colW}% + 2px)`,
                          width:  `calc(${colW}% - 4px)`,
                          height: `${height}px`,
                        }}
                      >
                        <div className="flex items-start gap-1">
                          <div className="w-3 flex-shrink-0">
                            <Icon size={10} className="mt-0.5 opacity-90" />
                          </div>
                          <div className="min-w-0">
                            <p
                              className="text-xs truncate leading-tight"
                              style={{ fontWeight: 700 }}
                            >
                              {event.subject}
                            </p>
                            {height > 32 && (
                              <p className="text-xs opacity-80 leading-tight">
                                {formatHour(event.startHour)}–{formatHour(event.endHour)}
                              </p>
                            )}
                          </div>
                        </div>
                      </EventComponent>
                    );
                  })}
                </div>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Add event button for professors and coordinators */}
      {(isProfessor || isCoordinator) && (
        <button
          onClick={() => setIsAddModalOpen(true)}
          className="fixed bottom-24 right-6 w-14 h-14 bg-[#008899] rounded-full flex items-center justify-center text-white shadow-lg hover:bg-[#007788] transition-colors z-40"
        >
          <Plus size={28} />
        </button>
      )}

      {/* Add Event Modal */}
      {isAddModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 px-4">
          <div className="bg-white rounded-2xl p-6 w-full max-w-sm">
            <h3 className="text-lg font-bold text-[#008899] mb-4">Añadir Nuevo Evento</h3>
            
            <div className="space-y-3">
              <div>
                <label className="block text-xs text-gray-500 mb-1">Tipo</label>
                <select
                  value={newEvent.type}
                  onChange={e => setNewEvent({...newEvent, type: e.target.value as EventType})}
                  className="w-full border border-gray-300 rounded-lg p-2 text-sm focus:outline-none focus:border-[#008899]"
                >
                  {isCoordinator && <option value="clase">Clase</option>}
                  <option value="entrega">Entrega</option>
                  <option value="examen">Examen</option>
                </select>
              </div>

              <div>
                <label className="block text-xs text-gray-500 mb-1">Asignatura / Título</label>
                <input
                  type="text"
                  value={newEvent.subject}
                  onChange={e => setNewEvent({...newEvent, subject: e.target.value})}
                  placeholder="Ej. Examen de Finanzas"
                  className="w-full border border-gray-300 rounded-lg p-2 text-sm focus:outline-none focus:border-[#008899]"
                />
              </div>

              <div>
                <label className="block text-xs text-gray-500 mb-1">Día de la semana</label>
                <select
                  value={newEvent.day}
                  onChange={e => setNewEvent({...newEvent, day: parseInt(e.target.value)})}
                  className="w-full border border-gray-300 rounded-lg p-2 text-sm focus:outline-none focus:border-[#008899]"
                >
                  {weekDays.map((d, i) => (
                    <option key={i} value={i}>{d.label}</option>
                  ))}
                </select>
              </div>

              <div className="flex gap-3">
                <div className="flex-1">
                  <label className="block text-xs text-gray-500 mb-1">Hora Inicio</label>
                  <select
                    value={newEvent.startHour}
                    onChange={e => setNewEvent({...newEvent, startHour: parseInt(e.target.value)})}
                    className="w-full border border-gray-300 rounded-lg p-2 text-sm focus:outline-none focus:border-[#008899]"
                  >
                    {hours.map(h => (
                      <option key={h} value={h}>{h}:00</option>
                    ))}
                  </select>
                </div>
                <div className="flex-1">
                  <label className="block text-xs text-gray-500 mb-1">Hora Fin</label>
                  <select
                    value={newEvent.endHour}
                    onChange={e => setNewEvent({...newEvent, endHour: parseInt(e.target.value)})}
                    className="w-full border border-gray-300 rounded-lg p-2 text-sm focus:outline-none focus:border-[#008899]"
                  >
                    {hours.map(h => (
                      <option key={h} value={h}>{h}:00</option>
                    ))}
                  </select>
                </div>
              </div>
            </div>

            <div className="flex gap-3 mt-6">
              <button
                onClick={() => setIsAddModalOpen(false)}
                className="flex-1 py-2 rounded-lg border border-gray-300 text-gray-600 text-sm font-semibold hover:bg-gray-50"
              >
                Cancelar
              </button>
              <button
                onClick={() => {
                  if (!newEvent.subject) return;
                  setEvents([...events, { id: Date.now(), ...newEvent } as CalEvent]);
                  setIsAddModalOpen(false);
                  setNewEvent({ type: 'examen', subject: '', day: 2, startHour: 10, endHour: 12 });
                }}
                className="flex-1 py-2 rounded-lg bg-[#008899] text-white text-sm font-semibold hover:bg-[#007788]"
              >
                Guardar
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Event Details Modal */}
      {selectedEvent && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 px-4" onClick={() => setSelectedEvent(null)}>
          <div className="bg-white rounded-2xl p-6 w-full max-w-sm relative" onClick={e => e.stopPropagation()}>
            <button
              onClick={() => setSelectedEvent(null)}
              className="absolute top-4 right-4 text-gray-400 hover:text-gray-600"
            >
              <X size={20} />
            </button>
            
            <div className="flex items-center gap-3 mb-4">
              <div className={`p-2 rounded-lg ${EVENT_STYLES[selectedEvent.type].bg}`}>
                {(() => {
                  const Icon = EVENT_ICONS[selectedEvent.type];
                  return <Icon size={20} className="text-white" />;
                })()}
              </div>
              <span className="text-sm font-bold text-gray-500 uppercase tracking-wider">
                {selectedEvent.type}
              </span>
            </div>
            
            <h3 className="text-xl font-bold text-[#008899] mb-4 leading-tight">{selectedEvent.subject}</h3>
            
            <div className="bg-gray-50 rounded-xl p-4 space-y-3 mb-6">
              <div className="flex justify-between items-center border-b border-gray-100 pb-2">
                <span className="text-sm text-gray-500">Día</span>
                <span className="text-sm font-semibold text-gray-800">
                  {selectedEvent.day >= 0 && selectedEvent.day < weekDays.length 
                    ? weekDays[selectedEvent.day].label 
                    : 'Próximamente'}
                </span>
              </div>
              {selectedEvent.day !== -1 && (
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-500">Horario</span>
                  <span className="text-sm font-semibold text-gray-800">
                    {formatHour(selectedEvent.startHour)} - {formatHour(selectedEvent.endHour)}
                  </span>
                </div>
              )}
            </div>

            <button
              onClick={() => setSelectedEvent(null)}
              className="w-full py-3 rounded-xl bg-[#008899] text-white text-sm font-semibold hover:bg-[#007788] transition-colors"
            >
              Cerrar
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
