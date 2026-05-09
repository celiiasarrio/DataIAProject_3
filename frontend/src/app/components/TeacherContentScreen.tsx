import { ChevronLeft, Link2, Plus, Trash2 } from 'lucide-react';
import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router';
import {
  createBlockContent,
  deleteContent,
  getBlockContent,
  getMyBlocks,
  uploadBlockContentFile,
  type BlockOut,
  type ContentOut,
} from '../api/client';
import { CenteredLoadingSpinner } from './ui/LoadingSpinner';

type ContentForm = {
  titulo: string;
  descripcion: string;
  tipo: string;
  url: string;
  file: File | null;
};

const emptyForm: ContentForm = {
  titulo: '',
  descripcion: '',
  tipo: 'link',
  url: '',
  file: null,
};

const formatDate = (value: string) =>
  new Intl.DateTimeFormat('es-ES', { day: '2-digit', month: 'short', year: 'numeric' }).format(new Date(value));

export function TeacherContentScreen() {
  const navigate = useNavigate();
  const [blocks, setBlocks] = useState<BlockOut[]>([]);
  const [blockId, setBlockId] = useState('');
  const [content, setContent] = useState<ContentOut[]>([]);
  const [formOpen, setFormOpen] = useState(false);
  const [form, setForm] = useState<ContentForm>(emptyForm);
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
    if (!blockId) {
      setContent([]);
      return;
    }
    setLoading(true);
    getBlockContent(blockId)
      .then(setContent)
      .catch(() => setContent([]))
      .finally(() => setLoading(false));
  }, [blockId]);

  const selectedBlock = useMemo(
    () => blocks.find((block) => block.id_bloque === blockId),
    [blocks, blockId],
  );

  const updateField = (key: keyof ContentForm, value: string) => {
    setForm((current) => ({ ...current, [key]: value }));
  };

  const handleSave = async () => {
    if (!blockId) return;
    if (!form.titulo.trim() || (!form.url.trim() && !form.file)) {
      setMessage('Completa título y URL.');
      return;
    }
    setSaving(true);
    setMessage(null);
    try {
      const created = form.file
        ? await uploadBlockContentFile(blockId, {
            titulo: form.titulo.trim(),
            descripcion: form.descripcion.trim() || null,
            tipo: form.tipo,
            file: form.file,
          })
        : await createBlockContent(blockId, {
            titulo: form.titulo.trim(),
            descripcion: form.descripcion.trim() || null,
            tipo: form.tipo,
            url: form.url.trim(),
          });
      setContent((current) => [created, ...current]);
      setForm(emptyForm);
      setFormOpen(false);
      setMessage('Contenido guardado');
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'No se ha podido guardar el contenido');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (contentId: string) => {
    setSaving(true);
    setMessage(null);
    try {
      await deleteContent(contentId);
      setContent((current) => current.filter((item) => item.id !== contentId));
      setMessage('Contenido eliminado');
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'No se ha podido eliminar el contenido');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#008899] pb-20">
      <div className="px-5 pt-12 pb-6">
        <div className="flex items-center gap-3 mb-5">
          <button onClick={() => navigate(-1)} className="p-1">
            <ChevronLeft className="text-white" size={24} />
          </button>
          <div className="flex-1">
            <h1 className="text-white text-xl" style={{ fontWeight: 600 }}>Material</h1>
            <p className="text-white text-xs opacity-80">{selectedBlock?.nombre ?? 'Contenido de asignaturas'}</p>
          </div>
          <button
            onClick={() => setFormOpen((open) => !open)}
            className="h-9 w-9 rounded-full bg-white/15 flex items-center justify-center text-white"
            aria-label="Nuevo contenido"
          >
            <Plus size={18} />
          </button>
        </div>

        <select
          value={blockId}
          onChange={(event) => setBlockId(event.target.value)}
          className="w-full rounded-xl bg-white/15 px-3 py-2 text-sm text-white focus:outline-none"
        >
          {blocks.map((block) => (
            <option key={block.id_bloque} value={block.id_bloque} className="text-black">
              {block.nombre}
            </option>
          ))}
        </select>
      </div>

      <div className="bg-white rounded-t-3xl px-5 pt-5 pb-6 min-h-[70vh]">
        {formOpen && (
          <div className="bg-gray-50 rounded-2xl p-4 mb-4 space-y-3">
            <label className="block">
              <span className="text-xs text-gray-400">Título</span>
              <input
                value={form.titulo}
                onChange={(event) => updateField('titulo', event.target.value)}
                className="mt-1 w-full rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#008899]"
              />
            </label>
            <div className="grid grid-cols-2 gap-3">
              <label className="block">
                <span className="text-xs text-gray-400">Tipo</span>
                <select
                  value={form.tipo}
                  onChange={(event) => updateField('tipo', event.target.value)}
                  className="mt-1 w-full rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#008899]"
                >
                  <option value="link">Enlace</option>
                  <option value="documento">Documento</option>
                  <option value="recurso">Recurso</option>
                </select>
              </label>
              <label className="block">
                <span className="text-xs text-gray-400">URL</span>
                <input
                  value={form.url}
                  onChange={(event) => updateField('url', event.target.value)}
                  disabled={Boolean(form.file)}
                  className="mt-1 w-full rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#008899]"
                />
              </label>
            </div>
            <label className="block">
              <span className="text-xs text-gray-400">Archivo</span>
              <input
                type="file"
                accept=".pdf,.doc,.docx,.ppt,.pptx,.xls,.xlsx,.txt,.zip"
                onChange={(event) => setForm((current) => ({ ...current, file: event.target.files?.[0] ?? null, url: event.target.files?.[0] ? '' : current.url }))}
                className="mt-1 w-full rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#008899]"
              />
            </label>
            <label className="block">
              <span className="text-xs text-gray-400">Descripción</span>
              <textarea
                value={form.descripcion}
                onChange={(event) => updateField('descripcion', event.target.value)}
                rows={3}
                className="mt-1 w-full rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#008899]"
              />
            </label>
            <div className="grid grid-cols-2 gap-2">
              <button
                onClick={() => {
                  setForm(emptyForm);
                  setFormOpen(false);
                  setMessage(null);
                }}
                disabled={saving}
                className="bg-gray-100 text-gray-700 py-3 rounded-xl text-sm"
                style={{ fontWeight: 700 }}
              >
                Cancelar
              </button>
              <button
                onClick={handleSave}
                disabled={saving}
                className="bg-[#008899] disabled:bg-gray-300 text-white py-3 rounded-xl text-sm"
                style={{ fontWeight: 700 }}
              >
                {saving ? 'Guardando...' : 'Guardar'}
              </button>
            </div>
          </div>
        )}

        {message && <p className="mb-4 text-center text-sm text-gray-500">{message}</p>}

        {loading ? (
          <CenteredLoadingSpinner />
        ) : content.length === 0 ? (
          <p className="text-gray-400 text-sm text-center py-8">No hay contenido publicado para este bloque.</p>
        ) : (
          <div className="space-y-3">
            {content.map((item) => (
              <div key={item.id} className="bg-gray-50 rounded-2xl p-4">
                <div className="flex items-start justify-between gap-3">
                  <div className="min-w-0">
                    <p className="text-gray-800 text-sm" style={{ fontWeight: 700 }}>{item.titulo}</p>
                    <p className="text-xs text-gray-400 mt-0.5">{item.tipo} · {formatDate(item.fecha_subida)}</p>
                  </div>
                  <button
                    onClick={() => handleDelete(item.id)}
                    disabled={saving}
                    className="p-2 text-red-500"
                    aria-label="Eliminar contenido"
                  >
                    <Trash2 size={16} />
                  </button>
                </div>
                {item.descripcion && <p className="text-sm text-gray-600 mt-2">{item.descripcion}</p>}
                <a
                  href={item.url}
                  target="_blank"
                  rel="noreferrer"
                  className="mt-3 inline-flex items-center gap-2 text-sm text-[#008899]"
                  style={{ fontWeight: 700 }}
                >
                  <Link2 size={14} />
                  Abrir recurso
                </a>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
