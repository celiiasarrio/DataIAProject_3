import { Plus } from 'lucide-react';

export function TasksScreen() {
  const tasks = [
    {
      title: 'Tareas de diseños',
      subtitle: 'En Miro',
      time: 'Vie 12 15:00',
      completed: false,
    },
    {
      title: 'Tareas de tramabilines',
      subtitle: 'En Miro',
      time: 'Vie 12 16:00',
      completed: false,
    },
    {
      title: 'Tareas de despiertos',
      subtitle: 'En Miro',
      time: 'Lun 15 10:15',
      completed: false,
    },
  ];

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
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-[#008899]" style={{ fontWeight: 600 }}>Lista de Tareas</h2>
          <span className="text-sm text-gray-500">Lunes martes y jueves</span>
        </div>

        {/* Tasks List */}
        <div className="space-y-3">
          {tasks.map((task, index) => (
            <div key={index} className="bg-white border border-gray-200 rounded-xl p-4">
              <div className="flex items-start gap-3">
                {/* Checkbox */}
                <div className="flex-shrink-0 mt-1">
                  <div className="w-5 h-5 rounded border-2 border-gray-300"></div>
                </div>
                
                {/* Content */}
                <div className="flex-1">
                  <h3 className="text-gray-800 mb-1" style={{ fontWeight: 600 }}>{task.title}</h3>
                  <p className="text-sm text-gray-500 mb-1">{task.subtitle}</p>
                  <p className="text-xs text-gray-400">{task.time}</p>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Add Button */}
        <button className="w-full bg-[#008899] text-white py-3 rounded-xl flex items-center justify-center gap-2 mt-6 hover:bg-[#007788] transition-colors">
          <span>Añadir Nueva</span>
          <Plus size={20} />
        </button>
      </div>
    </div>
  );
}
