import { ChevronLeft, Send } from 'lucide-react';
import { useNavigate } from 'react-router';

export function ChatScreen() {
  const navigate = useNavigate();

  return (
    <div className="min-h-screen bg-white flex flex-col pb-20">
      {/* Header */}
      <div className="bg-[#008899] px-6 pt-12 pb-4">
        <div className="flex items-center gap-3">
          <button onClick={() => navigate(-1)}>
            <ChevronLeft className="text-white" size={24} />
          </button>
          <div className="flex items-center gap-3 flex-1">
            <div className="w-10 h-10 bg-white/30 rounded-full flex items-center justify-center">
              <span className="text-white text-sm">LG</span>
            </div>
            <div>
              <h3 className="text-white" style={{ fontWeight: 600 }}>Dr. L. García (MA)</h3>
            </div>
          </div>
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 px-6 py-6 space-y-4 overflow-y-auto">
        {/* Received message 1 */}
        <div className="flex items-start gap-2">
          <div className="w-8 h-8 bg-gray-300 rounded-full flex items-center justify-center flex-shrink-0">
            <span className="text-white text-xs">LG</span>
          </div>
          <div className="bg-gray-100 rounded-2xl rounded-tl-none px-4 py-3 max-w-[75%]">
            <p className="text-sm text-gray-800">¿A qué hora nos reunimos el lunes para comentar la presentación que vais a hacer el miércoles? ¿Os viene bien a las 11?</p>
          </div>
        </div>

        {/* Received message 2 */}
        <div className="flex items-start gap-2">
          <div className="w-8 h-8 bg-gray-300 rounded-full flex items-center justify-center flex-shrink-0">
            <span className="text-white text-xs">LG</span>
          </div>
          <div className="bg-gray-100 rounded-2xl rounded-tl-none px-4 py-3 max-w-[75%]">
            <p className="text-sm text-gray-800">Necesitamos ultimar los últimos detalles sobre el proyecto y acordar el orden de intervención</p>
          </div>
        </div>

        {/* Sent message */}
        <div className="flex justify-end">
          <div className="bg-[#008899] rounded-2xl rounded-tr-none px-4 py-3 max-w-[75%]">
            <p className="text-sm text-white">¡Hola profe! A mí me viene muy bien por la mañana. Estaré allí puntual a las 11</p>
          </div>
        </div>

        {/* Received message 3 */}
        <div className="flex items-start gap-2">
          <div className="w-8 h-8 bg-gray-300 rounded-full flex items-center justify-center flex-shrink-0">
            <span className="text-white text-xs">LG</span>
          </div>
          <div className="bg-gray-100 rounded-2xl rounded-tl-none px-4 py-3 max-w-[75%]">
            <p className="text-sm text-gray-800">¿Cómo vais?</p>
          </div>
        </div>

        {/* Sent message 2 */}
        <div className="flex justify-end">
          <div className="bg-[#008899] rounded-2xl rounded-tr-none px-4 py-3 max-w-[75%]">
            <p className="text-sm text-white">Vamos avanzando muy bien. Un poco de estrés por terminar las diapositivas!</p>
          </div>
        </div>
      </div>

      {/* Input Area */}
      <div className="px-6 py-4 border-t border-gray-200 bg-white">
        <div className="flex items-center gap-2">
          <input
            type="text"
            placeholder="Escribe mensaje..."
            className="flex-1 px-4 py-2 bg-gray-100 rounded-full focus:outline-none focus:ring-2 focus:ring-[#008899]"
          />
          <button className="bg-[#008899] p-3 rounded-full">
            <Send className="text-white" size={20} />
          </button>
        </div>
      </div>
    </div>
  );
}
