import { Bell } from 'lucide-react';
import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router';

export function DashboardScreen() {
  const navigate = useNavigate();
  const [userRole, setUserRole] = useState<string | null>(null);

  useEffect(() => {
    // On component mount, check the role from localStorage
    setUserRole(localStorage.getItem('userRole'));
  }, []);
  
  return (
    <div className="min-h-screen bg-[#f5f5f5] pb-20">
      {/* Header */}
      <div className="bg-[#008899] px-6 pt-12 pb-6 rounded-b-3xl">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-white text-2xl mb-1" style={{ fontWeight: 300, fontFamily: 'Didot, Bodoni, serif' }}>EDEM</h1>
            <p className="text-white text-xs opacity-90">EDEM STUDENT HUB</p>
          </div>
          <Bell className="text-white" size={24} onClick={() => navigate('/notifications')}/>
        </div>
      </div>

      {/* Content */}
      <div className="px-6 -mt-4">
        {/* Mi Calendario */}
        <div 
          className="bg-white rounded-xl p-4 mb-4 shadow-sm cursor-pointer"
          onClick={() => navigate('/calendar')}
        >
          <h3 className="text-[#008899] mb-3" style={{ fontWeight: 600 }}>MI CALENDARIO</h3>
          <div className="grid grid-cols-7 gap-1 mb-3">
            {['L', 'M', 'X', 'J', 'V', 'S', 'D'].map((day, i) => (
              <div key={i} className="text-center text-xs text-gray-500">{day}</div>
            ))}
          </div>
          <div className="grid grid-cols-7 gap-1">
            {[28, 29, 30, 31, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 1].map((day, i) => (
              <div
                key={i}
                className={`aspect-square flex items-center justify-center text-xs rounded ${
                  day === 15 ? 'bg-[#008899] text-white' : i >= 4 && i <= 31 ? 'text-gray-800' : 'text-gray-400'
                }`}
              >
                {day}
              </div>
            ))}
          </div>
        </div>

        {/* Reserva de Salas */}
        <div className="bg-[#008899] rounded-xl p-4 mb-4 shadow-sm">
          <h3 className="text-white mb-2" style={{ fontWeight: 600 }}>RESERVA DE SALAS</h3>
          <p className="text-white text-xs opacity-90 mb-2">Encuentra tu espacio ideal</p>
          <button 
            onClick={() => navigate('/rooms')}
            className="bg-white text-[#008899] px-4 py-2 rounded-lg text-sm w-full"
          >
            Buscar Sala
          </button>
        </div>

        {/* Notas & Asistencia */}
        {userRole === 'student' && (
          <div className="grid grid-cols-2 gap-3 mb-4">
            <div
              className="bg-white rounded-xl p-4 shadow-sm cursor-pointer hover:shadow-md transition-shadow"
              onClick={() => navigate('/grades')}
            >
              <h3 className="text-[#008899] mb-1" style={{ fontWeight: 600 }}>MIS NOTAS</h3>
              <p className="text-gray-500 text-xs">Media: 7.83</p>
              <p className="text-2xl mt-1" style={{ fontWeight: 800, color: '#008899' }}>📊</p>
            </div>
            <div
              className="bg-white rounded-xl p-4 shadow-sm cursor-pointer hover:shadow-md transition-shadow"
              onClick={() => navigate('/attendance')}
            >
              <h3 className="text-[#008899] mb-1" style={{ fontWeight: 600 }}>ASISTENCIA</h3>
              <p className="text-gray-500 text-xs">Global: 89%</p>
              <p className="text-2xl mt-1" style={{ fontWeight: 800, color: '#008899' }}>📋</p>
            </div>
          </div>
        )}

        {userRole && userRole !== 'student' && (
          <div
            className="bg-white rounded-xl p-4 shadow-sm cursor-pointer hover:shadow-md transition-shadow mb-4"
            onClick={() => navigate('/attendance')}
          >
            <h3 className="text-[#008899] mb-1" style={{ fontWeight: 600 }}>MI ASISTENCIA</h3>
            <p className="text-gray-500 text-xs">Registra tu asistencia a clase</p>
            <p className="text-2xl mt-1" style={{ fontWeight: 800, color: '#008899' }}>📋</p>
          </div>
        )}
      </div>
    </div>
  );
}
