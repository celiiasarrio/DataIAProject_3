export function SettingsScreen() {
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
      <div className="bg-white rounded-t-3xl px-6 pt-6 pb-6 min-h-[80vh]">
        <h2 className="text-[#008899] mb-8" style={{ fontWeight: 600 }}>Ajustes de la App</h2>

        {/* Settings List */}
        <div className="space-y-6">
          {/* Notificaciones */}
          <div className="flex items-center justify-between">
            <span className="text-gray-800">Notificaciones</span>
            <button className="relative inline-flex h-6 w-11 items-center rounded-full bg-[#008899]">
              <span className="inline-block h-4 w-4 transform rounded-full bg-white translate-x-6 transition-transform" />
            </button>
          </div>

          {/* Cambiar Contraseña */}
          <div className="flex items-center justify-between">
            <span className="text-gray-800">Cambiar Contraseña</span>
            <button className="relative inline-flex h-6 w-11 items-center rounded-full bg-[#008899]">
              <span className="inline-block h-4 w-4 transform rounded-full bg-white translate-x-6 transition-transform" />
            </button>
          </div>

          {/* Seguridad */}
          <div className="flex items-center justify-between">
            <span className="text-gray-800">Seguridad</span>
            <button className="relative inline-flex h-6 w-11 items-center rounded-full bg-gray-300">
              <span className="inline-block h-4 w-4 transform rounded-full bg-white translate-x-1 transition-transform" />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
