import { ChevronLeft, Send, Sparkles } from 'lucide-react';
import { FormEvent, useMemo, useState } from 'react';
import { useNavigate } from 'react-router';
import { sendAgentMessage, type AgentChatMessage } from '../api/client';


const WELCOME_MESSAGE =
  'Soy tu asistente del campus. Puedo ayudarte con notas, asistencia, sesiones, calendario, tutorías, correos y notificaciones.';


export function ChatScreen() {
  const navigate = useNavigate();
  const userName = localStorage.getItem('userName') || 'Usuario';
  const [messages, setMessages] = useState<AgentChatMessage[]>([
    { role: 'assistant', content: WELCOME_MESSAGE },
  ]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const conversationHistory = useMemo(
    () => messages.filter((message) => message.content !== WELCOME_MESSAGE),
    [messages],
  );

  const handleSubmit = async (event: FormEvent) => {
    event.preventDefault();
    const trimmed = input.trim();
    if (!trimmed || loading) return;

    const nextUserMessage: AgentChatMessage = { role: 'user', content: trimmed };
    const historyForRequest = conversationHistory.slice(-10);

    setMessages((current) => [...current, nextUserMessage]);
    setInput('');
    setLoading(true);
    setError(null);

    try {
      const response = await sendAgentMessage(trimmed, historyForRequest);
      setMessages((current) => [...current, { role: 'assistant', content: response.reply }]);
    } catch (err) {
      const message = err instanceof Error ? err.message : 'No se pudo contactar con el asistente';
      setError(message);
      setMessages((current) => [
        ...current,
        {
          role: 'assistant',
          content: 'No he podido responder ahora mismo. Revisa la conexión con el agente y vuelve a intentarlo.',
        },
      ]);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-white flex flex-col pb-20">
      <div className="bg-[#008899] px-6 pt-12 pb-4">
        <div className="flex items-center gap-3">
          <button onClick={() => navigate(-1)}>
            <ChevronLeft className="text-white" size={24} />
          </button>
          <div className="flex items-center gap-3 flex-1">
            <div className="w-10 h-10 bg-white/25 rounded-full flex items-center justify-center">
              <Sparkles className="text-white" size={18} />
            </div>
            <div>
              <h3 className="text-white" style={{ fontWeight: 600 }}>Asistente Campus</h3>
              <p className="text-white/80 text-xs">{userName}</p>
            </div>
          </div>
        </div>
      </div>

      <div className="flex-1 px-6 py-6 space-y-4 overflow-y-auto bg-[#f8fbfc]">
        {messages.map((message, index) => (
          <div
            key={`${message.role}-${index}`}
            className={message.role === 'user' ? 'flex justify-end' : 'flex items-start gap-2'}
          >
            {message.role === 'assistant' && (
              <div className="w-8 h-8 bg-[#008899] rounded-full flex items-center justify-center flex-shrink-0">
                <Sparkles className="text-white" size={14} />
              </div>
            )}
            <div
              className={
                message.role === 'user'
                  ? 'bg-[#008899] rounded-2xl rounded-tr-none px-4 py-3 max-w-[80%]'
                  : 'bg-white rounded-2xl rounded-tl-none px-4 py-3 max-w-[80%] border border-[#d8ebee]'
              }
            >
              <p className={message.role === 'user' ? 'text-sm text-white' : 'text-sm text-gray-800'}>
                {message.content}
              </p>
            </div>
          </div>
        ))}

        {loading && (
          <div className="flex items-start gap-2">
            <div className="w-8 h-8 bg-[#008899] rounded-full flex items-center justify-center flex-shrink-0">
              <Sparkles className="text-white" size={14} />
            </div>
            <div className="bg-white rounded-2xl rounded-tl-none px-4 py-3 border border-[#d8ebee]">
              <p className="text-sm text-gray-500">Pensando...</p>
            </div>
          </div>
        )}
      </div>

      <div className="px-6 py-4 border-t border-gray-200 bg-white">
        {error && <p className="text-xs text-red-500 mb-2">{error}</p>}
        <form onSubmit={handleSubmit} className="flex items-center gap-2">
          <input
            type="text"
            placeholder="Pregúntame algo del campus..."
            value={input}
            onChange={(e) => setInput(e.target.value)}
            disabled={loading}
            className="flex-1 px-4 py-2 bg-gray-100 rounded-full focus:outline-none focus:ring-2 focus:ring-[#008899] disabled:opacity-70"
          />
          <button
            type="submit"
            disabled={loading || !input.trim()}
            className="bg-[#008899] p-3 rounded-full disabled:opacity-60"
          >
            <Send className="text-white" size={20} />
          </button>
        </form>
      </div>
    </div>
  );
}
