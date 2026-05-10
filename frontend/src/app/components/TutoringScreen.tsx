import { ChevronLeft, Send, Check, X, Trash2, Clock } from 'lucide-react';
import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router';
import {
  createTutoringRequest,
  getMyTutoringRequests,
  getReceivedTutoringRequests,
  acceptTutoringRequest,
  rejectTutoringRequest,
  proposeAlternativeTutoring,
  acceptAlternativeTutoring,
  rejectAlternativeTutoring,
  cancelTutoringRequest,
  getTutoringRecipients,
  type TutoringRecipientOut,
  type SolicitudTutoriaOut,
} from '../api/client';
import { CenteredLoadingSpinner } from './ui/LoadingSpinner';

const formatDateTime = (dateTime: string) => {
  const date = new Date(dateTime);
  return new Intl.DateTimeFormat('es-ES', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  }).format(date);
};

const getStatusColor = (estado: string) => {
  const colors: Record<string, string> = {
    'Pendiente': 'bg-amber-100 text-amber-700',
    'Aceptada': 'bg-green-100 text-green-700',
    'Rechazada': 'bg-red-100 text-red-700',
    'Propuesta alternativa': 'bg-blue-100 text-blue-700',
    'Cancelada': 'bg-gray-100 text-gray-600',
  };
  return colors[estado] || 'bg-gray-100 text-gray-600';
};

const getRecipientName = (recipients: TutoringRecipientOut[], id: string) => {
  const recipient = recipients.find((item) => item.id === id);
  return recipient ? `${recipient.nombre} ${recipient.apellido}` : id;
};

export function TutoringScreen() {
  const navigate = useNavigate();
  const [role] = useState(() => localStorage.getItem('userRole') || 'student');
  const [recipients, setRecipients] = useState<TutoringRecipientOut[]>([]);
  const [requests, setRequests] = useState<SolicitudTutoriaOut[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [showForm, setShowForm] = useState(false);

  const isStudent = role === 'student';

  const [form, setForm] = useState({
    id_profesor: '',
    motivo: '',
    opcion1_fecha_hora: '',
    opcion2_fecha_hora: '',
    opcion3_fecha_hora: '',
    comentario_alumno: '',
  });

  const [propuestaForm, setPropuestaForm] = useState<Record<string, string>>({});

  useEffect(() => {
    Promise.all([
      getTutoringRecipients(),
      isStudent ? getMyTutoringRequests() : getReceivedTutoringRequests(),
    ])
      .then(([items, reqs]) => {
        setRecipients(items);
        setRequests(reqs);
        if (isStudent && items.length > 0 && !form.id_profesor) {
          setForm(prev => ({ ...prev, id_profesor: items[0].id }));
        }
      })
      .catch(() => {
        setRecipients([]);
        setRequests([]);
      })
      .finally(() => setLoading(false));
  }, [isStudent]);

  const handleSubmit = async () => {
    if (!form.id_profesor || !form.motivo || !form.opcion1_fecha_hora || !form.opcion2_fecha_hora) {
      setMessage('Completa al menos: destinatario, motivo y 2 opciones de fecha/hora');
      return;
    }

    setSaving(true);
    setMessage(null);
    try {
      const payload = {
        id_profesor: form.id_profesor,
        motivo: form.motivo,
        opcion1_fecha_hora: new Date(form.opcion1_fecha_hora).toISOString(),
        opcion2_fecha_hora: new Date(form.opcion2_fecha_hora).toISOString(),
        opcion3_fecha_hora: form.opcion3_fecha_hora ? new Date(form.opcion3_fecha_hora).toISOString() : undefined,
        comentario_alumno: form.comentario_alumno || undefined,
      };
      const newRequest = await createTutoringRequest(payload);
      setRequests([newRequest, ...requests]);
      setForm({
        id_profesor: recipients[0]?.id || '',
        motivo: '',
        opcion1_fecha_hora: '',
        opcion2_fecha_hora: '',
        opcion3_fecha_hora: '',
        comentario_alumno: '',
      });
      setShowForm(false);
      setMessage('Solicitud enviada correctamente');
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Error al enviar solicitud');
    } finally {
      setSaving(false);
    }
  };

  const handleAccept = async (requestId: string, option: 1 | 2 | 3) => {
    setSaving(true);
    try {
      const updated = await acceptTutoringRequest(requestId, option);
      setRequests(requests.map(r => r.id === requestId ? updated : r));
      setMessage('Opción aceptada');
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Error al aceptar');
    } finally {
      setSaving(false);
    }
  };

  const handleReject = async (requestId: string) => {
    setSaving(true);
    try {
      const updated = await rejectTutoringRequest(requestId);
      setRequests(requests.map(r => r.id === requestId ? updated : r));
      setMessage('Solicitud rechazada');
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Error al rechazar');
    } finally {
      setSaving(false);
    }
  };

  const handleProposeAlternative = async (requestId: string) => {
    const propuesta = propuestaForm[requestId];
    if (!propuesta) {
      setMessage('Ingresa una fecha/hora alternativa');
      return;
    }

    setSaving(true);
    try {
      const updated = await proposeAlternativeTutoring(requestId, new Date(propuesta).toISOString());
      setRequests(requests.map(r => r.id === requestId ? updated : r));
      setPropuestaForm(prev => {
        const next = { ...prev };
        delete next[requestId];
        return next;
      });
      setMessage('Propuesta alternativa enviada');
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Error al proponer alternativa');
    } finally {
      setSaving(false);
    }
  };

  const handleAcceptAlternative = async (requestId: string) => {
    setSaving(true);
    try {
      const updated = await acceptAlternativeTutoring(requestId);
      setRequests(requests.map(r => r.id === requestId ? updated : r));
      setMessage('Propuesta alternativa aceptada');
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Error al aceptar propuesta');
    } finally {
      setSaving(false);
    }
  };

  const handleRejectAlternative = async (requestId: string) => {
    setSaving(true);
    try {
      const updated = await rejectAlternativeTutoring(requestId);
      setRequests(requests.map(r => r.id === requestId ? updated : r));
      setMessage('Propuesta alternativa rechazada');
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Error al rechazar propuesta');
    } finally {
      setSaving(false);
    }
  };

  const handleCancel = async (requestId: string) => {
    setSaving(true);
    try {
      const updated = await cancelTutoringRequest(requestId);
      setRequests(requests.map(r => r.id === requestId ? updated : r));
      setMessage('Solicitud cancelada');
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Error al cancelar');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#f5f5f5] pb-20">
      <div className="bg-[#008899] px-5 pt-12 pb-6">
        <div className="flex items-center gap-3">
          <button onClick={() => navigate(-1)} className="p-1">
            <ChevronLeft className="text-white" size={24} />
          </button>
          <div>
            <h1 className="text-white text-xl" style={{ fontWeight: 600 }}>Tutorías</h1>
            <p className="text-white text-xs opacity-80">{isStudent ? 'Mis solicitudes' : 'Solicitudes recibidas'}</p>
          </div>
        </div>
      </div>

      <div className="px-5 pt-6">
        {loading ? (
          <CenteredLoadingSpinner />
        ) : isStudent ? (
          <>
            {!showForm ? (
              <button
                onClick={() => setShowForm(true)}
                className="w-full bg-[#008899] text-white py-3 rounded-xl mb-4 hover:bg-[#007788] transition-colors"
                style={{ fontWeight: 600 }}
              >
                + Nueva solicitud de tutoría
              </button>
            ) : (
              <div className="bg-white rounded-xl p-4 mb-4 shadow-sm">
                <label className="block mb-3">
                  <span className="text-xs text-gray-400">Profesor o coordinador</span>
                  <select
                    value={form.id_profesor}
                    onChange={(e) => setForm({ ...form, id_profesor: e.target.value })}
                    className="mt-1 w-full rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#008899]"
                  >
                    {recipients.map((recipient) => (
                      <option key={recipient.id} value={recipient.id}>
                        {recipient.nombre} {recipient.apellido} · {recipient.rol === 'coordinador' ? 'Coordinador' : 'Profesor'}
                      </option>
                    ))}
                  </select>
                </label>

                <label className="block mb-3">
                  <span className="text-xs text-gray-400">Motivo</span>
                  <textarea
                    value={form.motivo}
                    onChange={(e) => setForm({ ...form, motivo: e.target.value })}
                    placeholder="Describe el motivo de la tutoría"
                    className="mt-1 w-full rounded-lg border border-gray-200 px-3 py-2 text-sm min-h-20 focus:outline-none focus:ring-2 focus:ring-[#008899]"
                  />
                </label>

                <label className="block mb-3">
                  <span className="text-xs text-gray-400">Opción 1 de fecha y hora</span>
                  <input
                    type="datetime-local"
                    value={form.opcion1_fecha_hora}
                    onChange={(e) => setForm({ ...form, opcion1_fecha_hora: e.target.value })}
                    className="mt-1 w-full rounded-lg border border-gray-200 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#008899]"
                  />
                </label>

                <label className="block mb-3">
                  <span className="text-xs text-gray-400">Opción 2 de fecha y hora</span>
                  <input
                    type="datetime-local"
                    value={form.opcion2_fecha_hora}
                    onChange={(e) => setForm({ ...form, opcion2_fecha_hora: e.target.value })}
                    className="mt-1 w-full rounded-lg border border-gray-200 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#008899]"
                  />
                </label>

                <label className="block mb-3">
                  <span className="text-xs text-gray-400">Opción 3 de fecha y hora (opcional)</span>
                  <input
                    type="datetime-local"
                    value={form.opcion3_fecha_hora}
                    onChange={(e) => setForm({ ...form, opcion3_fecha_hora: e.target.value })}
                    className="mt-1 w-full rounded-lg border border-gray-200 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#008899]"
                  />
                </label>

                <label className="block mb-4">
                  <span className="text-xs text-gray-400">Comentario adicional (opcional)</span>
                  <textarea
                    value={form.comentario_alumno}
                    onChange={(e) => setForm({ ...form, comentario_alumno: e.target.value })}
                    placeholder="Información adicional"
                    className="mt-1 w-full rounded-lg border border-gray-200 px-3 py-2 text-sm min-h-16 focus:outline-none focus:ring-2 focus:ring-[#008899]"
                  />
                </label>

                {message && <p className="text-center text-sm text-gray-500 mb-3">{message}</p>}

                <div className="grid grid-cols-2 gap-2">
                  <button
                    onClick={() => setShowForm(false)}
                    className="bg-gray-100 text-gray-700 py-2 rounded-lg hover:bg-gray-200 transition-colors"
                    style={{ fontWeight: 600 }}
                  >
                    Cancelar
                  </button>
                  <button
                    onClick={handleSubmit}
                    disabled={saving}
                    className="bg-[#008899] disabled:bg-gray-300 text-white py-2 rounded-lg hover:bg-[#007788] transition-colors flex items-center justify-center gap-2"
                    style={{ fontWeight: 600 }}
                  >
                    <Send size={16} />
                    Enviar
                  </button>
                </div>
              </div>
            )}

            <h2 className="text-[#008899] mb-3" style={{ fontWeight: 700 }}>Mis solicitudes</h2>
            {requests.length === 0 ? (
              <p className="text-gray-500 text-sm text-center py-8">No tienes solicitudes aún</p>
            ) : (
              <div className="space-y-3">
                {requests.map(req => (
                  <div key={req.id} className="bg-white rounded-xl p-4 shadow-sm">
                    <div className="flex items-start justify-between mb-2">
                      <div>
                        <p className="text-sm text-gray-600">{getRecipientName(recipients, req.id_profesor)}</p>
                        <p className="text-sm font-medium text-gray-800">{req.motivo}</p>
                      </div>
                      <span className={`text-xs px-2 py-1 rounded-lg ${getStatusColor(req.estado)}`}>
                        {req.estado}
                      </span>
                    </div>

                    {req.estado === 'Aceptada' && req.fecha_hora_confirmada && (
                      <div className="bg-green-50 rounded-lg p-2 mb-2 flex items-center gap-2">
                        <Clock size={14} className="text-green-600" />
                        <span className="text-xs text-green-700">{formatDateTime(req.fecha_hora_confirmada)}</span>
                      </div>
                    )}

                    {req.estado === 'Propuesta alternativa' && req.propuesta_alternativa_fecha_hora && (
                      <div className="bg-blue-50 rounded-lg p-2 mb-2">
                        <p className="text-xs text-blue-700 mb-1">Propuesta alternativa:</p>
                        <p className="text-xs text-blue-700 font-medium">{formatDateTime(req.propuesta_alternativa_fecha_hora)}</p>
                        <div className="grid grid-cols-2 gap-2 mt-2">
                          <button
                            onClick={() => handleAcceptAlternative(req.id)}
                            disabled={saving}
                            className="text-xs bg-green-500 text-white py-1 rounded flex items-center justify-center gap-1 hover:bg-green-600 transition-colors"
                          >
                            <Check size={12} /> Aceptar
                          </button>
                          <button
                            onClick={() => handleRejectAlternative(req.id)}
                            disabled={saving}
                            className="text-xs bg-red-500 text-white py-1 rounded flex items-center justify-center gap-1 hover:bg-red-600 transition-colors"
                          >
                            <X size={12} /> Rechazar
                          </button>
                        </div>
                      </div>
                    )}

                    {req.estado === 'Pendiente' && (
                      <div className="bg-amber-50 rounded-lg p-2 mb-2 space-y-1">
                        <p className="text-xs text-amber-700 font-medium">Opciones propuestas:</p>
                        <p className="text-xs text-amber-700">1. {formatDateTime(req.opcion1_fecha_hora)}</p>
                        <p className="text-xs text-amber-700">2. {formatDateTime(req.opcion2_fecha_hora)}</p>
                        {req.opcion3_fecha_hora && (
                          <p className="text-xs text-amber-700">3. {formatDateTime(req.opcion3_fecha_hora)}</p>
                        )}
                      </div>
                    )}

                    {req.estado === 'Pendiente' && (
                      <button
                        onClick={() => handleCancel(req.id)}
                        disabled={saving}
                        className="text-xs bg-red-50 text-red-600 py-1 px-2 rounded hover:bg-red-100 transition-colors w-full flex items-center justify-center gap-1"
                      >
                        <Trash2 size={12} /> Cancelar solicitud
                      </button>
                    )}
                  </div>
                ))}
              </div>
            )}
          </>
        ) : (
          <>
            <h2 className="text-[#008899] mb-3" style={{ fontWeight: 700 }}>Solicitudes recibidas</h2>
            {requests.length === 0 ? (
              <p className="text-gray-500 text-sm text-center py-8">No tienes solicitudes pendientes</p>
            ) : (
              <div className="space-y-3">
                {requests.map(req => (
                  <div key={req.id} className="bg-white rounded-xl p-4 shadow-sm">
                    <div className="flex items-start justify-between mb-2">
                      <div>
                        <p className="text-sm text-gray-600">De: Estudiante {req.id_alumno}</p>
                        <p className="text-sm font-medium text-gray-800">{req.motivo}</p>
                      </div>
                      <span className={`text-xs px-2 py-1 rounded-lg ${getStatusColor(req.estado)}`}>
                        {req.estado}
                      </span>
                    </div>

                    {req.estado === 'Pendiente' && (
                      <div className="bg-amber-50 rounded-lg p-2 mb-2 space-y-1">
                        <p className="text-xs text-amber-700 font-medium">Opciones propuestas:</p>
                        <p className="text-xs text-amber-700">1. {formatDateTime(req.opcion1_fecha_hora)}</p>
                        <p className="text-xs text-amber-700">2. {formatDateTime(req.opcion2_fecha_hora)}</p>
                        {req.opcion3_fecha_hora && (
                          <p className="text-xs text-amber-700">3. {formatDateTime(req.opcion3_fecha_hora)}</p>
                        )}
                        {req.comentario_alumno && (
                          <p className="text-xs text-amber-700 italic mt-1">Nota: {req.comentario_alumno}</p>
                        )}

                        <div className="grid grid-cols-3 gap-2 mt-2">
                          <button
                            onClick={() => handleAccept(req.id, 1)}
                            disabled={saving}
                            className="text-xs bg-green-500 text-white py-1 rounded hover:bg-green-600 transition-colors"
                          >
                            Op. 1
                          </button>
                          <button
                            onClick={() => handleAccept(req.id, 2)}
                            disabled={saving}
                            className="text-xs bg-green-500 text-white py-1 rounded hover:bg-green-600 transition-colors"
                          >
                            Op. 2
                          </button>
                          {req.opcion3_fecha_hora && (
                            <button
                              onClick={() => handleAccept(req.id, 3)}
                              disabled={saving}
                              className="text-xs bg-green-500 text-white py-1 rounded hover:bg-green-600 transition-colors"
                            >
                              Op. 3
                            </button>
                          )}
                        </div>

                        <button
                          onClick={() => handleReject(req.id)}
                          disabled={saving}
                          className="w-full text-xs bg-red-50 text-red-600 py-1 rounded hover:bg-red-100 transition-colors mt-2"
                        >
                          Rechazar
                        </button>

                        <div className="mt-2 pt-2 border-t border-amber-200">
                          <input
                            type="datetime-local"
                            value={propuestaForm[req.id] || ''}
                            onChange={(e) => setPropuestaForm({ ...propuestaForm, [req.id]: e.target.value })}
                            placeholder="Proponer otra fecha/hora"
                            className="w-full text-xs rounded-lg border border-amber-300 px-2 py-1 focus:outline-none focus:ring-2 focus:ring-blue-500 mb-1"
                          />
                          <button
                            onClick={() => handleProposeAlternative(req.id)}
                            disabled={saving}
                            className="w-full text-xs bg-blue-500 text-white py-1 rounded hover:bg-blue-600 transition-colors"
                          >
                            Proponer alternativa
                          </button>
                        </div>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
}
