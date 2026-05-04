import React, { useState, useRef, useEffect } from 'react';
import {
  Camera, Edit2, Check, X, Mail, Linkedin,
  GraduationCap, BadgeCheck, Hash,
} from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { useNavigate } from 'react-router';
import { getMyProfile, uploadProfilePhoto, deleteProfilePhoto } from '../api/client';

const DEFAULT_PHOTO = 'https://images.unsplash.com/photo-1600180758890-6b94519a8ba6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMG1hbGUlMjBzdHVkZW50JTIwcHJvZmVzc2lvbmFsJTIwaGVhZHNob3R8ZW58MXx8fHwxNzc0NDUzMDQ4fDA&ixlib=rb-4.1.0&q=80&w=1080';

type Role = 'Alumno' | 'Profesor' | 'Coordinador';

const ROLE_COLORS: Record<Role, { bg: string; text: string }> = {
  Alumno:       { bg: 'bg-blue-100',   text: 'text-blue-700'   },
  Profesor:     { bg: 'bg-purple-100', text: 'text-purple-700' },
  Coordinador:  { bg: 'bg-teal-100',   text: 'text-teal-700'   },
};

function mapRolToDisplay(rol: string): Role {
  if (rol === 'profesor') return 'Profesor';
  if (rol === 'personal') return 'Coordinador';
  return 'Alumno';
}

export function ProfileScreen() {
  const navigate = useNavigate();
  const [photoUrl, setPhotoUrl]         = useState(DEFAULT_PHOTO);
  const [userRole, setUserRole]         = useState<string | null>(null);
  const [isEditingContact, setEditContact] = useState(false);

  const [nombre, setNombre]   = useState('');
  const [apellido, setApellido] = useState('');
  const [userId, setUserId]   = useState('');
  const [role, setRole]       = useState<Role>('Alumno');

  const [email,    setEmail]    = useState('');
  const [linkedin, setLinkedin] = useState('');
  const [tmpEmail,    setTmpEmail]    = useState('');
  const [tmpLinkedin, setTmpLinkedin] = useState('');

  const fileInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    const storedRole = localStorage.getItem('userRole');
    setUserRole(storedRole);

    getMyProfile()
      .then((profile) => {
        setNombre(profile.nombre);
        setApellido(profile.apellido);
        setUserId(profile.id);
        setEmail(profile.correo);
        setTmpEmail(profile.correo);
        setRole(mapRolToDisplay(profile.rol));
        if (profile.url_foto) setPhotoUrl(profile.url_foto);
      })
      .catch(() => {
        // Fallback to localStorage values if API fails
        setNombre(localStorage.getItem('userName')?.split(' ')[0] || '');
        setApellido(localStorage.getItem('userName')?.split(' ').slice(1).join(' ') || '');
        setEmail(localStorage.getItem('userEmail') || '');
        setTmpEmail(localStorage.getItem('userEmail') || '');
      });
  }, []);

  const isAdmin = userRole === 'admin';
  const isProfessor = userRole === 'professor';

  const handlePhotoChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setPhotoUrl(URL.createObjectURL(file));
    try {
      const result = await uploadProfilePhoto(file);
      setPhotoUrl(result.url_foto);
    } catch {
      // preview stays but upload failed silently
    }
  };

  const handleDeletePhoto = async () => {
    try {
      await deleteProfilePhoto();
      setPhotoUrl(DEFAULT_PHOTO);
    } catch {
      // ignore
    }
  };

  const handleSaveContact = () => {
    setEmail(tmpEmail);
    setLinkedin(tmpLinkedin);
    setEditContact(false);
  };

  const handleCancelContact = () => {
    setTmpEmail(email);
    setTmpLinkedin(linkedin);
    setEditContact(false);
  };

  const startEditContact = () => {
    setTmpEmail(email);
    setTmpLinkedin(linkedin);
    setEditContact(true);
  };

  const roleStyle = ROLE_COLORS[role];

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('userRole');
    localStorage.removeItem('userId');
    localStorage.removeItem('userName');
    localStorage.removeItem('userEmail');
    localStorage.removeItem('userPhoto');
    navigate('/');
  };

  return (
    <div className="min-h-screen bg-[#f5f5f5] pb-20">
      {/* ── Header ── */}
      <div className="bg-[#008899] px-6 pt-12 pb-28 rounded-b-3xl relative">
        <h1 className="text-white text-xl mb-1" style={{ fontWeight: 300, fontFamily: 'Didot, Bodoni, serif' }}>EDEM</h1>
        <p className="text-white text-xs opacity-80 mb-6">EDEM STUDENT HUB</p>

        {/* Avatar */}
        <div className="flex flex-col items-center">
          <div className="relative">
            <div className="w-24 h-24 rounded-full overflow-hidden border-4 border-white shadow-lg">
              <ImageWithFallback
                src={photoUrl}
                alt="Foto de perfil"
                className="w-full h-full object-cover"
              />
            </div>
            {/* Camera button */}
            <button
              onClick={() => fileInputRef.current?.click()}
              className="absolute bottom-0 right-0 w-8 h-8 bg-white rounded-full border-2 border-[#008899] flex items-center justify-center shadow hover:bg-gray-50 transition-colors"
            >
              <Camera size={14} className="text-[#008899]" />
            </button>
            {/* Delete photo button — only shown when user has a custom photo */}
            {photoUrl !== DEFAULT_PHOTO && (
              <button
                onClick={handleDeletePhoto}
                className="absolute top-0 right-0 w-6 h-6 bg-red-500 rounded-full flex items-center justify-center shadow hover:bg-red-600 transition-colors"
              >
                <X size={10} className="text-white" />
              </button>
            )}
            <input
              ref={fileInputRef}
              type="file"
              accept="image/*"
              className="hidden"
              onChange={handlePhotoChange}
            />
          </div>

          <h2 className="text-white text-xl mt-3" style={{ fontWeight: 700 }}>
            {nombre} {apellido}
          </h2>

          {/* Role badge */}
          <span
            className={`mt-2 px-3 py-0.5 rounded-full text-xs ${roleStyle.bg} ${roleStyle.text}`}
            style={{ fontWeight: 600 }}
          >
            {role}
          </span>
        </div>
      </div>

      {/* ── Cards ── */}
      <div className="px-5 -mt-14 space-y-3">
        {/* Matrícula & Curso */}
        <div className="bg-white rounded-2xl shadow-sm p-4 space-y-3">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl bg-[#008899]/10 flex items-center justify-center flex-shrink-0">
              <Hash size={18} className="text-[#008899]" />
            </div>
            <div>
              <p className="text-xs text-gray-400">ID</p>
              <p className="text-gray-800" style={{ fontWeight: 600 }}>{userId || '—'}</p>
            </div>
          </div>

          <div className="h-px bg-gray-100" />

          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl bg-[#008899]/10 flex items-center justify-center flex-shrink-0">
              <GraduationCap size={18} className="text-[#008899]" />
            </div>
            <div>
              <p className="text-xs text-gray-400">Rol</p>
              <p className="text-gray-800" style={{ fontWeight: 600 }}>{role}</p>
            </div>
          </div>

          <div className="h-px bg-gray-100" />

          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl bg-[#008899]/10 flex items-center justify-center flex-shrink-0">
              <BadgeCheck size={18} className="text-[#008899]" />
            </div>
            <div>
              <p className="text-xs text-gray-400">Tipo</p>
              <span
                className={`text-sm px-2 py-0.5 rounded-full ${roleStyle.bg} ${roleStyle.text}`}
                style={{ fontWeight: 600 }}
              >
                {role}
              </span>
            </div>
          </div>
        </div>

        {/* Contact info */}
        <div className="bg-white rounded-2xl shadow-sm p-4">
          <div className="flex items-center justify-between mb-3">
            <p className="text-gray-800" style={{ fontWeight: 700 }}>Contacto</p>
            {!isEditingContact ? (
              <button
                onClick={startEditContact}
                className="flex items-center gap-1 text-[#008899] text-sm hover:opacity-80 transition-opacity"
              >
                <Edit2 size={14} />
                <span>Editar</span>
              </button>
            ) : (
              <div className="flex gap-2">
                <button
                  onClick={handleCancelContact}
                  className="w-7 h-7 rounded-full bg-gray-100 flex items-center justify-center hover:bg-gray-200 transition-colors"
                >
                  <X size={14} className="text-gray-500" />
                </button>
                <button
                  onClick={handleSaveContact}
                  className="w-7 h-7 rounded-full bg-[#008899] flex items-center justify-center hover:bg-[#007788] transition-colors"
                >
                  <Check size={14} className="text-white" />
                </button>
              </div>
            )}
          </div>

          {/* Email */}
          <div className="flex items-center gap-3 mb-3">
            <div className="w-9 h-9 rounded-xl bg-blue-50 flex items-center justify-center flex-shrink-0">
              <Mail size={18} className="text-blue-500" />
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-xs text-gray-400">Correo electrónico</p>
              {isEditingContact ? (
                <input
                  type="email"
                  value={tmpEmail}
                  onChange={e => setTmpEmail(e.target.value)}
                  className="w-full text-sm text-gray-800 border-b border-[#008899] outline-none bg-transparent py-0.5"
                  style={{ fontWeight: 500 }}
                />
              ) : (
                <p className="text-sm text-gray-800 truncate" style={{ fontWeight: 500 }}>{email}</p>
              )}
            </div>
          </div>

          <div className="h-px bg-gray-100 mb-3" />

          {/* LinkedIn */}
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl bg-blue-50 flex items-center justify-center flex-shrink-0">
              <Linkedin size={18} className="text-blue-700" />
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-xs text-gray-400">LinkedIn</p>
              {isEditingContact ? (
                <input
                  type="text"
                  value={tmpLinkedin}
                  onChange={e => setTmpLinkedin(e.target.value)}
                  className="w-full text-sm text-gray-800 border-b border-[#008899] outline-none bg-transparent py-0.5"
                  style={{ fontWeight: 500 }}
                />
              ) : (
                <p className="text-sm text-blue-600 truncate" style={{ fontWeight: 500 }}>
                  {linkedin || '—'}
                </p>
              )}
            </div>
          </div>
        </div>

        {/* Quick access buttons */}
        {isAdmin ? (
          <div className="pt-2 grid grid-cols-1 gap-3">
            <button
              onClick={() => navigate('/courses')}
              className="bg-[#008899] text-white py-3 rounded-2xl text-sm w-full hover:bg-[#007788] transition-colors"
              style={{ fontWeight: 600 }}
            >
              📚 Mis Cursos
            </button>
            <button
              onClick={() => navigate('/teacher/grades')}
              className="bg-white text-[#008899] border border-[#008899] py-3 rounded-2xl text-sm w-full hover:bg-[#008899]/5 transition-colors"
              style={{ fontWeight: 600 }}
            >
              Gestionar notas
            </button>
          </div>
        ) : isProfessor ? (
          <div className="pt-2 grid grid-cols-1 gap-3">
            <button
              onClick={() => navigate('/teacher/grades')}
              className="bg-[#008899] text-white py-3 rounded-2xl text-sm w-full hover:bg-[#007788] transition-colors"
              style={{ fontWeight: 600 }}
            >
              👨‍🎓 Calificar Alumnos
            </button>
          </div>
        ) : (
          <div className="grid grid-cols-2 gap-3">
            <button onClick={() => navigate('/grades')} className="bg-[#008899] text-white py-3 rounded-2xl text-sm hover:bg-[#007788] transition-colors" style={{ fontWeight: 600 }}>
              📊 Mis Notas
            </button>
            <button onClick={() => navigate('/attendance')} className="bg-white text-[#008899] border border-[#008899] py-3 rounded-2xl text-sm hover:bg-[#008899]/5 transition-colors" style={{ fontWeight: 600 }}>
              📋 Asistencia
            </button>
          </div>
        )}

        {/* Logout Button */}
        <div className="pt-3">
          <button
            onClick={handleLogout}
            className="bg-white text-red-600 border border-red-300 py-3 rounded-2xl text-sm w-full hover:bg-red-50 transition-colors"
            style={{ fontWeight: 600 }}
          >
            🚪 Cerrar Sesión
          </button>
        </div>
      </div>
    </div>
  );
}
