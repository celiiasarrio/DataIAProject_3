import { useEffect, useState } from 'react';
import { Search, ChevronDown } from 'lucide-react';

export function RoomBookingScreen() {
  const [userRole, setUserRole] = useState<string | null>(null);

  useEffect(() => {
    setUserRole(localStorage.getItem('userRole'));
  }, []);

  const isProfessor = userRole === 'professor';

  return (
    <div className="min-h-screen bg-[#008899] pb-20">
      {/* Header */}
      <div className="px-6 pt-12 pb-6">
        <div>
          <h1 className="text-white text-xl mb-1" style={{ fontWeight: 300, fontFamily: 'Didot, Bodoni, serif' }}>EDEM</h1>
          <p className="text-white text-xs opacity-90">EDEM STUDENT HUB</p>
        </div>
      </div>

      {/* Content */}
      <div className="bg-white rounded-t-3xl px-6 pt-6 pb-6">
        <h2 className="text-[#008899] mb-6" style={{ fontWeight: 600 }}>
          {isProfessor ? 'Reservar Sala para Tutorías' : 'Reserva de Salas'}
        </h2>

        {/* Search Bar */}
        <div className="relative mb-6">
          <input
            type="text"
            placeholder="Buscar"
            className="w-full pl-4 pr-12 py-3 bg-gray-100 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#008899]"
          />
          <button className="absolute right-2 top-1/2 -translate-y-1/2 bg-[#008899] p-2 rounded-lg">
            <Search className="text-white" size={20} />
          </button>
        </div>

        {/* Filters */}
        <div className="space-y-4">
          {/* Ubicación */}
          <div>
            <label className="block text-gray-700 mb-2 text-sm">Ubicación</label>
            <div className="relative">
              <select className="w-full px-4 py-3 bg-gray-100 rounded-lg appearance-none focus:outline-none focus:ring-2 focus:ring-[#008899]">
                <option>EDEM 0</option>
                <option>EDEM 1</option>
              </select>
              <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500" size={20} />
            </div>
          </div>

          {/* Hora */}
          <div>
            <label className="block text-gray-700 mb-2 text-sm">Hora</label>
            <div className="grid grid-cols-2 gap-3">
              <div className="relative">
                <select className="w-full px-4 py-3 bg-gray-100 rounded-lg appearance-none focus:outline-none focus:ring-2 focus:ring-[#008899]">
                  <option>08:00-15:00</option>
                </select>
                <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500" size={20} />
              </div>
              <div className="relative">
                <select className="w-full px-4 py-3 bg-gray-100 rounded-lg appearance-none focus:outline-none focus:ring-2 focus:ring-[#008899]">
                  <option>Año</option>
                </select>
                <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500" size={20} />
              </div>
            </div>
          </div>

          {/* Aforo */}
          <div>
            <label className="block text-gray-700 mb-2 text-sm">Aforo</label>
            <div className="relative">
              <select className="w-full px-4 py-3 bg-gray-100 rounded-lg appearance-none focus:outline-none focus:ring-2 focus:ring-[#008899]">
                <option>Seleccionar</option>
                <option>1-5 personas</option>
                <option>6-10 personas</option>
                <option>11-20 personas</option>
                <option>20+ personas</option>
              </select>
              <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500" size={20} />
            </div>
          </div>
        </div>

        {/* Filter Button */}
        <button className="w-full bg-[#008899] text-white py-3 rounded-lg mt-8 hover:bg-[#007788] transition-colors">
          Filtrar
        </button>
      </div>
    </div>
  );
}
