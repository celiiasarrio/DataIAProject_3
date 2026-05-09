import React, { useEffect, useMemo, useRef, useState } from 'react';
import {
  BadgeCheck,
  BriefcaseBusiness,
  Camera,
  Check,
  ChevronLeft,
  Download,
  FileText,
  Github,
  Globe,
  GraduationCap,
  IdCard,
  Linkedin,
  Lock,
  Mail,
  PenLine,
  Phone,
  Save,
  ShieldCheck,
  Trash2,
  Upload,
  User,
  X,
} from 'lucide-react';
import { useNavigate } from 'react-router';
import {
  assetUrl,
  changeProfilePassword,
  deleteProfileCv,
  deleteProfileDocument,
  getFullProfile,
  replaceProfileDocument,
  updateProfileSection,
  uploadProfileCv,
  uploadProfileDocument,
  uploadProfilePhoto,
  type ProfileDocument,
  type ProfileFull,
} from '../api/client';
import { CenteredLoadingSpinner } from './ui/LoadingSpinner';
import { ImageWithFallback } from './figma/ImageWithFallback';

const DOC_TYPES = ['DNI/NIE', 'Matricula', 'Certificado', 'Convenio practicas', 'Autorizacion', 'Otro'];

type EditableSection = 'personal' | 'contact' | 'professional';

const TRANSLATIONS = {
  es: {
    back: 'Volver',
    edit: 'Editar',
    saveOk: 'Cambios guardados',
    academic: 'Informacion academica/profesional',
    personal: 'Datos personales',
    contact: 'Contacto',
    professional: 'Perfil profesional',
    documents: 'Documentacion',
    preferences: 'Preferencias',
    security: 'Seguridad y cuenta',
    upload: 'Subir',
    replace: 'Reemplazar',
    delete: 'Eliminar',
    view: 'Ver',
    close: 'Cerrar sesion',
    password: 'Cambiar contraseña',
  },
  en: {
    back: 'Back',
    edit: 'Edit',
    saveOk: 'Saved',
    academic: 'Academic/professional info',
    personal: 'Personal data',
    contact: 'Contact',
    professional: 'Professional profile',
    documents: 'Documents',
    preferences: 'Preferences',
    security: 'Security and account',
    upload: 'Upload',
    replace: 'Replace',
    delete: 'Delete',
    view: 'View',
    close: 'Sign out',
    password: 'Change password',
  },
  ca: {
    back: 'Tornar',
    edit: 'Editar',
    saveOk: 'Canvis guardats',
    academic: 'Informacio academica/professional',
    personal: 'Dades personals',
    contact: 'Contacte',
    professional: 'Perfil professional',
    documents: 'Documentacio',
    preferences: 'Preferencies',
    security: 'Seguretat i compte',
    upload: 'Pujar',
    replace: 'Reemplaçar',
    delete: 'Eliminar',
    view: 'Veure',
    close: 'Tancar sessio',
    password: 'Canviar contrasenya',
  },
};

function logout(navigate: ReturnType<typeof useNavigate>) {
  localStorage.removeItem('token');
  localStorage.removeItem('userRole');
  localStorage.removeItem('userId');
  localStorage.removeItem('userName');
  localStorage.removeItem('userEmail');
  localStorage.removeItem('userPhoto');
  navigate('/');
}

function valueOrAdd(value: unknown, placeholder: string) {
  return value ? String(value) : <span className="text-gray-400">{placeholder}</span>;
}

function Card({
  title,
  icon: Icon,
  children,
  onEdit,
  editing,
  onCancel,
  onSave,
}: {
  title: string;
  icon: React.ElementType;
  children: React.ReactNode;
  onEdit?: () => void;
  editing?: boolean;
  onCancel?: () => void;
  onSave?: () => void;
}) {
  return (
    <section className="bg-white dark:bg-gray-900 rounded-2xl shadow-sm p-4">
      <div className="flex items-center justify-between gap-3 mb-4">
        <div className="flex items-center gap-2">
          <div className="w-9 h-9 rounded-xl bg-[#008899]/10 flex items-center justify-center">
            <Icon size={18} className="text-[#008899]" />
          </div>
          <h2 className="text-gray-900 dark:text-gray-100 text-sm" style={{ fontWeight: 800 }}>{title}</h2>
        </div>
        {onEdit && !editing && (
          <button onClick={onEdit} className="text-[#008899] dark:text-cyan-300 text-xs flex items-center gap-1">
            <PenLine size={14} /> Editar
          </button>
        )}
        {editing && (
          <div className="flex gap-2">
            <button onClick={onCancel} className="w-8 h-8 rounded-full bg-gray-100 dark:bg-gray-800 flex items-center justify-center">
              <X size={14} className="text-gray-500" />
            </button>
            <button onClick={onSave} className="w-8 h-8 rounded-full bg-[#008899] flex items-center justify-center">
              <Save size={14} className="text-white" />
            </button>
          </div>
        )}
      </div>
      {children}
    </section>
  );
}

function InfoGrid({ items }: { items: Array<[string, React.ReactNode]> }) {
  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
      {items.map(([label, value]) => (
        <div key={label} className="rounded-xl bg-gray-50 dark:bg-gray-800 px-3 py-2">
          <p className="text-xs text-gray-400 dark:text-gray-500 mb-0.5">{label}</p>
          <div className="text-sm text-gray-800 dark:text-gray-100 break-words" style={{ fontWeight: 600 }}>{value}</div>
        </div>
      ))}
    </div>
  );
}

function TextInput({
  label,
  value,
  onChange,
  placeholder,
  multiline,
  type = 'text',
}: {
  label: string;
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  multiline?: boolean;
  type?: string;
}) {
  return (
    <label className="block">
      <span className="text-xs text-gray-400">{label}</span>
      {multiline ? (
        <textarea
          value={value}
          onChange={(event) => onChange(event.target.value)}
          placeholder={placeholder}
          className="mt-1 w-full min-h-20 rounded-xl border border-gray-200 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-100 px-3 py-2 text-sm outline-none focus:border-[#008899]"
        />
      ) : (
        <input
          type={type}
          value={value}
          onChange={(event) => onChange(event.target.value)}
          placeholder={placeholder}
          className="mt-1 w-full rounded-xl border border-gray-200 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-100 px-3 py-2 text-sm outline-none focus:border-[#008899]"
        />
      )}
    </label>
  );
}

function ToggleRow({ label, checked, onChange }: { label: string; checked: boolean; onChange: (value: boolean) => void }) {
  return (
    <label className="flex items-center justify-between gap-3 rounded-xl bg-gray-50 dark:bg-gray-800 px-3 py-2">
      <span className="text-sm text-gray-700 dark:text-gray-100">{label}</span>
      <input type="checkbox" checked={checked} onChange={(event) => onChange(event.target.checked)} className="h-4 w-4 accent-[#008899]" />
    </label>
  );
}

function SelectInput({
  label,
  value,
  onChange,
  options,
}: {
  label: string;
  value: string;
  onChange: (value: string) => void;
  options: Array<{ value: string; label: string }>;
}) {
  return (
    <label className="block">
      <span className="text-xs text-gray-400">{label}</span>
      <select
        value={value}
        onChange={(event) => onChange(event.target.value)}
        className="mt-1 w-full rounded-xl border border-gray-200 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-100 px-3 py-2 text-sm outline-none focus:border-[#008899]"
      >
        {options.map((option) => (
          <option key={option.value} value={option.value}>{option.label}</option>
        ))}
      </select>
    </label>
  );
}

export function ProfileScreen() {
  const navigate = useNavigate();
  const avatarInputRef = useRef<HTMLInputElement>(null);
  const cvInputRef = useRef<HTMLInputElement>(null);
  const docInputRef = useRef<HTMLInputElement>(null);
  const replaceDocInputRef = useRef<HTMLInputElement>(null);
  const [profile, setProfile] = useState<ProfileFull | null>(null);
  const [loading, setLoading] = useState(true);
  const [editing, setEditing] = useState<EditableSection | null>(null);
  const [form, setForm] = useState<Record<string, string | boolean>>({});
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [docType, setDocType] = useState(DOC_TYPES[0]);
  const [replaceDoc, setReplaceDoc] = useState<ProfileDocument | null>(null);
  const [passwordForm, setPasswordForm] = useState({ current: '', next: '', repeat: '' });

  useEffect(() => {
    getFullProfile()
      .then(setProfile)
      .catch((err) => setError(err instanceof Error ? err.message : 'No se pudo cargar el perfil'))
      .finally(() => setLoading(false));
  }, []);

  const photoUrl = assetUrl(profile?.url_foto);
  const isStudent = profile?.rol === 'Alumno';
  const isProfessor = profile?.rol === 'Profesor';
  const fullName = `${profile?.nombre ?? ''} ${profile?.apellido ?? ''}`.trim();
  const isDark = profile?.tema === 'oscuro';
  const locale = profile?.idioma_app === 'en' ? 'en-GB' : profile?.idioma_app === 'ca' ? 'ca-ES' : 'es-ES';
  const t = TRANSLATIONS[(profile?.idioma_app as keyof typeof TRANSLATIONS) || 'es'] ?? TRANSLATIONS.es;
  const formatDate = (value: string | null) => {
    if (!value) return null;
    const parts = value.match(/^(\d{4})-(\d{2})-(\d{2})$/);
    if (parts) return `${parts[3]}-${parts[2]}-${parts[1]}`;
    return value;
  };

  const academicItems = useMemo(() => {
    if (!profile) return [];
    if (isStudent) {
      return [
        ['Programa formativo', valueOrAdd(profile.programa_area, 'Programa pendiente')],
        ['Curso academico', valueOrAdd(profile.curso_academico, 'Anadir curso')],
        ['Grupo', valueOrAdd(profile.grupo, 'Anadir grupo')],
        ['Promocion', valueOrAdd(profile.promocion, 'Anadir promocion')],
        ['Campus', valueOrAdd(profile.campus, 'Anadir campus')],
        ['Modalidad', valueOrAdd(profile.modalidad, 'Anadir modalidad')],
        ['Coordinador/a', valueOrAdd(profile.coordinador_asignado, 'Sin coordinador asignado')],
        ['Tutor/a academico', valueOrAdd(profile.tutor_academico, 'Sin tutor asignado')],
        ['Fecha inicio', valueOrAdd(formatDate(profile.fecha_inicio), 'Anadir fecha')],
        ['Fin estimado', valueOrAdd(formatDate(profile.fecha_fin_estimada), 'Anadir fecha')],
      ];
    }
    if (isProfessor) {
      return [
        ['Departamento', valueOrAdd(profile.departamento_area, 'Anadir departamento')],
        ['Asignaturas', profile.asignaturas.length ? profile.asignaturas.join(', ') : valueOrAdd('', 'Sin asignaturas')],
        ['Especialidad', valueOrAdd(profile.especialidad, 'Anadir especialidad')],
        ['Tutorias', valueOrAdd(profile.horario_tutorias, 'Sin horario publicado')],
        ['Correo institucional', profile.correo],
        ['Disponibilidad', valueOrAdd(profile.disponibilidad_contacto, 'Anadir disponibilidad')],
      ];
    }
    return [
      ['Programas', profile.programas_coordina.length ? profile.programas_coordina.join(', ') : valueOrAdd('', 'Sin programas')],
      ['Grupos asignados', profile.grupos_asignados.length ? profile.grupos_asignados.join(', ') : valueOrAdd('', 'Sin grupos')],
      ['Area coordinacion', valueOrAdd(profile.area_coordinacion, 'Anadir area')],
      ['Horario atencion', valueOrAdd(profile.horario_atencion, 'Anadir horario')],
      ['Permisos', profile.permisos_administrativos.join(', ')],
    ];
  }, [profile, isStudent, isProfessor]);

  const beginEdit = (section: EditableSection) => {
    if (!profile) return;
    setEditing(section);
    setError(null);
    setMessage(null);
    const base: Record<string, string | boolean> = {
      nombre: profile.nombre ?? '',
      apellido: profile.apellido ?? '',
      telefono: profile.telefono ?? '',
      ciudad: profile.ciudad ?? '',
      idioma_preferido: profile.idioma_preferido ?? '',
      contacto_emergencia: profile.contacto_emergencia ?? '',
      correo_personal: profile.correo_personal ?? '',
      linkedin: profile.linkedin ?? '',
      github: profile.github ?? '',
      portfolio: profile.portfolio ?? '',
      preferencia_contacto: profile.preferencia_contacto ?? '',
      area_interes: profile.area_interes ?? '',
      stack_tecnologico: profile.stack_tecnologico ?? '',
      experiencia_actual: profile.experiencia_actual ?? '',
      disponibilidad: profile.disponibilidad ?? '',
      preferencia_jornada: profile.preferencia_jornada ?? '',
      idioma_app: profile.idioma_app,
      notificaciones_email: profile.notificaciones_email,
      notificaciones_push: profile.notificaciones_push,
      visibilidad_profesional: profile.visibilidad_profesional,
      permitir_cv_empleabilidad: profile.permitir_cv_empleabilidad,
      permitir_links_profesores: profile.permitir_links_profesores,
      tema: profile.tema,
    };
    setForm(base);
  };

  const setField = (key: string, value: string | boolean) => setForm((current) => ({ ...current, [key]: value }));

  const saveSection = async () => {
    if (!editing) return;
    try {
      const fieldsBySection: Record<EditableSection, string[]> = {
        personal: ['nombre', 'apellido', 'telefono', 'ciudad', 'idioma_preferido', 'contacto_emergencia'],
        contact: ['correo_personal', 'telefono', 'linkedin', 'github', 'portfolio', 'preferencia_contacto'],
        professional: ['area_interes', 'stack_tecnologico', 'experiencia_actual', 'disponibilidad', 'preferencia_jornada', 'linkedin', 'github', 'portfolio'],
      };
      const payload = Object.fromEntries(fieldsBySection[editing].map((key) => [key, form[key]]));
      const updatedProfile = await updateProfileSection(editing, payload);
      setProfile(updatedProfile);
      localStorage.setItem('profileTheme', updatedProfile.tema);
      localStorage.setItem('profileLanguage', updatedProfile.idioma_app);
      setMessage(t.saveOk);
      setEditing(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'No se pudo guardar');
    }
  };

  const uploadAvatar = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file || !profile) return;
    try {
      const updated = await uploadProfilePhoto(file);
      setProfile({ ...profile, url_foto: updated.url_foto });
      setMessage('Foto actualizada');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'No se pudo subir la foto');
    }
  };

  const uploadCv = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;
    try {
      setProfile(await uploadProfileCv(file));
      setMessage('CV actualizado');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'No se pudo subir el CV');
    }
  };

  const removeCv = async () => {
    setProfile(await deleteProfileCv());
  };

  const uploadDocument = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file || !profile) return;
    try {
      const document = await uploadProfileDocument(docType, file);
      setProfile({ ...profile, documentos: [document, ...profile.documentos] });
      setMessage('Documento subido');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'No se pudo subir el documento');
    } finally {
      event.target.value = '';
    }
  };

  const replaceDocument = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file || !profile || !replaceDoc) return;
    const updated = await replaceProfileDocument(replaceDoc.id, replaceDoc.tipo, file);
    setProfile({
      ...profile,
      documentos: profile.documentos.map((doc) => (doc.id === updated.id ? updated : doc)),
    });
    setReplaceDoc(null);
    event.target.value = '';
  };

  const removeDocument = async (id: string) => {
    if (!profile) return;
    await deleteProfileDocument(id);
    setProfile({ ...profile, documentos: profile.documentos.filter((doc) => doc.id !== id) });
  };

  const changePassword = async () => {
    if (passwordForm.next !== passwordForm.repeat) {
      setError('La nueva contraseña no coincide');
      return;
    }
    try {
      const response = await changeProfilePassword(passwordForm.current, passwordForm.next);
      setPasswordForm({ current: '', next: '', repeat: '' });
      setMessage(response.mensaje);
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'No se pudo cambiar la contraseña');
    }
  };

  if (loading) {
    return <div className="min-h-screen bg-[#f5f5f5] flex items-center justify-center"><CenteredLoadingSpinner size="lg" /></div>;
  }

  if (!profile) {
    return <div className="min-h-screen bg-[#f5f5f5] flex items-center justify-center text-red-500">{error ?? 'Perfil no disponible'}</div>;
  }

  return (
    <div className={isDark ? 'dark' : ''}>
    <div className="min-h-screen bg-[#f5f5f5] dark:bg-gray-950 pb-24">
      <div className="bg-[#008899] px-5 pt-12 pb-24 rounded-b-3xl">
        <button onClick={() => navigate(-1)} className="mb-4 flex items-center gap-1 text-white/90 text-sm">
          <ChevronLeft size={18} /> {t.back}
        </button>
        <div className="flex flex-col sm:flex-row items-center sm:items-end gap-4">
          <div className="relative">
            <div className="w-28 h-28 rounded-full overflow-hidden border-4 border-white shadow-lg bg-white/20 flex items-center justify-center">
              {photoUrl ? (
                <ImageWithFallback src={photoUrl} alt="Foto de perfil" className="w-full h-full object-cover" />
              ) : (
                <User size={42} className="text-white" />
              )}
            </div>
            <button
              onClick={() => avatarInputRef.current?.click()}
              className="absolute bottom-1 right-1 w-9 h-9 bg-white rounded-full border-2 border-[#008899] flex items-center justify-center shadow"
            >
              <Camera size={16} className="text-[#008899]" />
            </button>
            <input ref={avatarInputRef} type="file" accept="image/jpeg,image/png,image/webp" className="hidden" onChange={uploadAvatar} />
          </div>
          <div className="text-center sm:text-left flex-1">
            <h1 className="text-white text-2xl" style={{ fontWeight: 800 }}>{fullName}</h1>
            <div className="mt-2 flex flex-wrap justify-center sm:justify-start gap-2">
              <span className="bg-white/90 text-[#008899] text-xs px-3 py-1 rounded-full" style={{ fontWeight: 700 }}>{profile.rol}</span>
              <span className="bg-white/15 text-white text-xs px-3 py-1 rounded-full">{profile.estado}</span>
            </div>
            <p className="text-white/80 text-sm mt-2">
              {profile.grupo ?? 'MDA A 2526'}
            </p>
          </div>
        </div>
      </div>

      <main className="px-5 -mt-14 space-y-4 max-w-5xl mx-auto">
        {(message || error) && (
          <div className={`rounded-2xl px-4 py-3 text-sm ${error ? 'bg-red-50 text-red-700' : 'bg-green-50 text-green-700'}`}>
            {error ?? message}
          </div>
        )}

        <Card title={t.academic} icon={isStudent ? GraduationCap : BriefcaseBusiness}>
          <InfoGrid items={academicItems} />
        </Card>

        <Card
          title={t.personal}
          icon={User}
          onEdit={() => beginEdit('personal')}
          editing={editing === 'personal'}
          onCancel={() => setEditing(null)}
          onSave={saveSection}
        >
          {editing === 'personal' ? (
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <TextInput label="Nombre" value={String(form.nombre ?? '')} onChange={(v) => setField('nombre', v)} />
              <TextInput label="Apellidos" value={String(form.apellido ?? '')} onChange={(v) => setField('apellido', v)} />
              <TextInput label="Telefono" value={String(form.telefono ?? '')} onChange={(v) => setField('telefono', v)} placeholder="Anadir telefono" />
              <TextInput label="Ciudad" value={String(form.ciudad ?? '')} onChange={(v) => setField('ciudad', v)} placeholder="Anadir ciudad" />
              <TextInput label="Idioma preferido" value={String(form.idioma_preferido ?? '')} onChange={(v) => setField('idioma_preferido', v)} placeholder="es" />
              <TextInput label="Contacto emergencia" value={String(form.contacto_emergencia ?? '')} onChange={(v) => setField('contacto_emergencia', v)} placeholder="Opcional" />
            </div>
          ) : (
            <InfoGrid
              items={[
                ['Nombre completo', fullName],
                ['Telefono', valueOrAdd(profile.telefono, 'Anadir telefono')],
                ['Ciudad', valueOrAdd(profile.ciudad, 'Anadir ciudad')],
                ['Idioma preferido', valueOrAdd(profile.idioma_preferido, 'Anadir idioma')],
                ['Contacto emergencia', valueOrAdd(profile.contacto_emergencia, 'Opcional')],
              ]}
            />
          )}
        </Card>

        <Card
          title={t.contact}
          icon={Mail}
          onEdit={() => beginEdit('contact')}
          editing={editing === 'contact'}
          onCancel={() => setEditing(null)}
          onSave={saveSection}
        >
          {editing === 'contact' ? (
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <TextInput label="Correo personal" value={String(form.correo_personal ?? '')} onChange={(v) => setField('correo_personal', v)} placeholder="Anadir correo" />
              <TextInput label="Telefono" value={String(form.telefono ?? '')} onChange={(v) => setField('telefono', v)} placeholder="Anadir telefono" />
              <TextInput label="LinkedIn" value={String(form.linkedin ?? '')} onChange={(v) => setField('linkedin', v)} placeholder="Anadir LinkedIn" />
              <TextInput label="GitHub" value={String(form.github ?? '')} onChange={(v) => setField('github', v)} placeholder="Anadir GitHub" />
              <TextInput label="Portfolio" value={String(form.portfolio ?? '')} onChange={(v) => setField('portfolio', v)} placeholder="Anadir portfolio" />
              <TextInput label="Preferencia contacto" value={String(form.preferencia_contacto ?? '')} onChange={(v) => setField('preferencia_contacto', v)} placeholder="email / telefono / plataforma" />
            </div>
          ) : (
            <InfoGrid
              items={[
                ['Correo EDEM', profile.correo],
                ['Correo personal', valueOrAdd(profile.correo_personal, 'Anadir correo personal')],
                ['Telefono', valueOrAdd(profile.telefono, 'Anadir telefono')],
                ['LinkedIn', valueOrAdd(profile.linkedin, 'Anadir LinkedIn')],
                ['GitHub', valueOrAdd(profile.github, 'Anadir GitHub')],
                ['Portfolio', valueOrAdd(profile.portfolio, 'Anadir portfolio')],
                ['Preferencia', valueOrAdd(profile.preferencia_contacto, 'email')],
              ]}
            />
          )}
        </Card>

        <Card
          title={t.professional}
          icon={BriefcaseBusiness}
          onEdit={() => beginEdit('professional')}
          editing={editing === 'professional'}
          onCancel={() => setEditing(null)}
          onSave={saveSection}
        >
          {editing === 'professional' ? (
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <TextInput label="Area de interes" value={String(form.area_interes ?? '')} onChange={(v) => setField('area_interes', v)} placeholder="Data, IA, producto..." />
              <TextInput label="Stack tecnologico" value={String(form.stack_tecnologico ?? '')} onChange={(v) => setField('stack_tecnologico', v)} placeholder="Python, SQL, Cloud..." />
              <TextInput label="Disponibilidad" value={String(form.disponibilidad ?? '')} onChange={(v) => setField('disponibilidad', v)} placeholder="Practicas / empleo" />
              <TextInput label="Jornada" value={String(form.preferencia_jornada ?? '')} onChange={(v) => setField('preferencia_jornada', v)} placeholder="Completa / parcial" />
              <TextInput label="LinkedIn" value={String(form.linkedin ?? '')} onChange={(v) => setField('linkedin', v)} />
              <TextInput label="GitHub" value={String(form.github ?? '')} onChange={(v) => setField('github', v)} />
              <TextInput label="Portfolio" value={String(form.portfolio ?? '')} onChange={(v) => setField('portfolio', v)} />
              <TextInput label="Experiencia actual" value={String(form.experiencia_actual ?? '')} onChange={(v) => setField('experiencia_actual', v)} multiline />
            </div>
          ) : (
            <>
              <InfoGrid
                items={[
                  ['Area interes', valueOrAdd(profile.area_interes, 'Anadir area')],
                  ['Stack', valueOrAdd(profile.stack_tecnologico, 'Anadir stack')],
                  ['Experiencia', valueOrAdd(profile.experiencia_actual, 'Anadir experiencia')],
                  ['Disponibilidad', valueOrAdd(profile.disponibilidad, 'Anadir disponibilidad')],
                  ['Jornada', valueOrAdd(profile.preferencia_jornada, 'Anadir jornada')],
                ]}
              />
              <div className="mt-3 rounded-xl bg-gray-50 p-3 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                <div>
                  <p className="text-xs text-gray-400">CV adjunto</p>
            <p className="text-sm text-gray-800 dark:text-gray-100" style={{ fontWeight: 600 }}>{profile.cv.nombre ?? 'Subir CV'}</p>
                </div>
                <div className="flex gap-2">
                  {profile.cv.url && (
                    <>
                      <a href={assetUrl(profile.cv.url)} target="_blank" rel="noreferrer" className="px-3 py-2 rounded-xl bg-white text-[#008899] text-xs flex items-center gap-1">
                        <Download size={14} /> {t.view}
                      </a>
                      <button onClick={removeCv} className="px-3 py-2 rounded-xl bg-red-50 text-red-600 text-xs flex items-center gap-1">
                        <Trash2 size={14} /> {t.delete}
                      </button>
                    </>
                  )}
                  <button onClick={() => cvInputRef.current?.click()} className="px-3 py-2 rounded-xl bg-[#008899] text-white text-xs flex items-center gap-1">
                    <Upload size={14} /> {profile.cv.url ? t.replace : t.upload}
                  </button>
                  <input ref={cvInputRef} type="file" accept="application/pdf" className="hidden" onChange={uploadCv} />
                </div>
              </div>
            </>
          )}
        </Card>

        <Card title={t.documents} icon={FileText}>
          <div className="flex flex-col sm:flex-row gap-2 mb-3">
            <select value={docType} onChange={(event) => setDocType(event.target.value)} className="rounded-xl border border-gray-200 px-3 py-2 text-sm bg-white">
              {DOC_TYPES.map((type) => <option key={type}>{type}</option>)}
            </select>
            <button onClick={() => docInputRef.current?.click()} className="rounded-xl bg-[#008899] text-white px-4 py-2 text-sm flex items-center justify-center gap-2">
              <Upload size={16} /> {t.upload} documento
            </button>
            <input ref={docInputRef} type="file" accept="application/pdf,image/jpeg,image/png" className="hidden" onChange={uploadDocument} />
            <input ref={replaceDocInputRef} type="file" accept="application/pdf,image/jpeg,image/png" className="hidden" onChange={replaceDocument} />
          </div>
          {profile.documentos.length === 0 ? (
            <p className="text-sm text-gray-400 rounded-xl bg-gray-50 p-4">No hay documentos subidos.</p>
          ) : (
            <div className="space-y-2">
              {profile.documentos.map((doc) => (
                <div key={doc.id} className="rounded-xl bg-gray-50 p-3 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                  <div>
                    <p className="text-sm text-gray-800" style={{ fontWeight: 700 }}>{doc.nombre}</p>
                    <p className="text-xs text-gray-400">{doc.tipo} · {new Date(doc.fecha_subida).toLocaleDateString('es-ES')} · {doc.estado}</p>
                  </div>
                  <div className="flex gap-2">
                    <a href={assetUrl(doc.url)} target="_blank" rel="noreferrer" className="px-3 py-2 rounded-xl bg-white text-[#008899] text-xs flex items-center gap-1">
                        <Download size={14} /> {t.view}
                    </a>
                    <button onClick={() => { setReplaceDoc(doc); replaceDocInputRef.current?.click(); }} className="px-3 py-2 rounded-xl bg-white text-gray-700 text-xs flex items-center gap-1">
                      <Upload size={14} /> {t.replace}
                    </button>
                    <button onClick={() => removeDocument(doc.id)} className="px-3 py-2 rounded-xl bg-red-50 text-red-600 text-xs flex items-center gap-1">
                      <Trash2 size={14} /> {t.delete}
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </Card>

        <Card title={t.security} icon={Lock}>
          <InfoGrid items={[
            ['Ultimo acceso', profile.ultimo_acceso ? new Date(profile.ultimo_acceso).toLocaleString(locale) : valueOrAdd('', 'No disponible')],
            [t.password, 'Disponible'],
          ]} />
          <div className="mt-4 grid grid-cols-1 sm:grid-cols-3 gap-3">
            <TextInput
              label="Contraseña actual"
              type="password"
              value={passwordForm.current}
              onChange={(value) => setPasswordForm((current) => ({ ...current, current: value }))}
            />
            <TextInput
              label="Nueva contraseña"
              type="password"
              value={passwordForm.next}
              onChange={(value) => setPasswordForm((current) => ({ ...current, next: value }))}
            />
            <TextInput
              label="Repetir contraseña"
              type="password"
              value={passwordForm.repeat}
              onChange={(value) => setPasswordForm((current) => ({ ...current, repeat: value }))}
            />
          </div>
          <button
            onClick={changePassword}
            className="mt-3 w-full rounded-2xl bg-[#008899] py-3 text-sm text-white hover:bg-[#007788]"
            style={{ fontWeight: 700 }}
          >
            {t.password}
          </button>
          <button
            onClick={() => logout(navigate)}
            className="mt-4 w-full rounded-2xl border border-red-200 bg-white py-3 text-sm text-red-600 hover:bg-red-50"
            style={{ fontWeight: 700 }}
          >
            {t.close}
          </button>
        </Card>
      </main>
    </div>
    </div>
  );
}
