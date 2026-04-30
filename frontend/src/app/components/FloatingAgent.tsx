import { Bot, Send, X } from 'lucide-react';
import { useEffect, useRef, useState, type KeyboardEvent } from 'react';
import { sendAgentMessage } from '../api/client';

interface ChatMessage {
  id: number;
  role: 'user' | 'agent';
  text: string;
}

export function FloatingAgent() {
  const [open, setOpen] = useState(false);
  const [messages, setMessages] = useState<ChatMessage[]>([
    {
      id: 0,
      role: 'agent',
      text: '¡Hola! Soy tu asistente del campus. Pregúntame por tus notas, asistencia, eventos del calendario o tutorías.',
    },
  ]);
  const [input, setInput] = useState('');
  const [sending, setSending] = useState(false);
  const [sessionId, setSessionId] = useState<string | undefined>(undefined);
  const scrollRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages, open]);

  useEffect(() => {
    if (open) inputRef.current?.focus();
  }, [open]);

  async function handleSend() {
    const text = input.trim();
    if (!text || sending) return;
    const userMsg: ChatMessage = { id: Date.now(), role: 'user', text };
    setMessages((prev) => [...prev, userMsg]);
    setInput('');
    setSending(true);
    try {
      const res = await sendAgentMessage(text, sessionId);
      if (res.session_id && !sessionId) setSessionId(res.session_id);
      setMessages((prev) => [
        ...prev,
        { id: Date.now() + 1, role: 'agent', text: res.reply },
      ]);
    } catch (err) {
      const detail = err instanceof Error ? err.message : 'Error desconocido';
      setMessages((prev) => [
        ...prev,
        {
          id: Date.now() + 1,
          role: 'agent',
          text: `No he podido contactar con el asistente (${detail}).`,
        },
      ]);
    } finally {
      setSending(false);
    }
  }

  function handleKeyDown(e: KeyboardEvent<HTMLInputElement>) {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  }

  return (
    <>
      {/* Floating button */}
      <button
        onClick={() => setOpen((v) => !v)}
        aria-label={open ? 'Cerrar asistente' : 'Abrir asistente'}
        className="fixed bottom-24 right-5 z-40 w-14 h-14 rounded-full flex items-center justify-center shadow-lg transition-transform hover:scale-105 active:scale-95"
        style={{
          backgroundColor: 'rgba(0, 136, 153, 0.75)',
          backdropFilter: 'blur(4px)',
          boxShadow: '0 0 20px rgba(0, 136, 153, 0.45), 0 6px 16px rgba(0, 0, 0, 0.15)',
        }}
      >
        {open ? (
          <X className="text-white" size={26} />
        ) : (
          <Bot className="text-white" size={28} />
        )}
      </button>

      {/* Chat panel */}
      {open && (
        <div
          role="dialog"
          aria-label="Asistente del campus"
          className="fixed bottom-44 right-5 z-40 w-[min(92vw,380px)] h-[min(70vh,520px)] bg-white rounded-2xl shadow-2xl flex flex-col overflow-hidden border border-gray-200"
        >
          {/* Header */}
          <div className="bg-[#008899] px-4 py-3 flex items-center gap-3">
            <div className="w-9 h-9 rounded-full bg-white/20 flex items-center justify-center">
              <Bot className="text-white" size={20} />
            </div>
            <div className="flex-1 min-w-0">
              <h3 className="text-white text-sm" style={{ fontWeight: 600 }}>
                Asistente EDEM
              </h3>
              <p className="text-white/80 text-xs">En línea</p>
            </div>
            <button
              onClick={() => setOpen(false)}
              aria-label="Cerrar"
              className="p-1 rounded hover:bg-white/10"
            >
              <X className="text-white" size={18} />
            </button>
          </div>

          {/* Messages */}
          <div
            ref={scrollRef}
            className="flex-1 px-4 py-3 space-y-3 overflow-y-auto bg-gray-50"
          >
            {messages.map((m) =>
              m.role === 'agent' ? (
                <div key={m.id} className="flex items-start gap-2">
                  <div className="w-7 h-7 rounded-full bg-[#008899] flex items-center justify-center flex-shrink-0">
                    <Bot className="text-white" size={14} />
                  </div>
                  <div className="bg-white border border-gray-200 rounded-2xl rounded-tl-none px-3 py-2 max-w-[80%]">
                    <p className="text-sm text-gray-800 whitespace-pre-wrap">{m.text}</p>
                  </div>
                </div>
              ) : (
                <div key={m.id} className="flex justify-end">
                  <div className="bg-[#008899] rounded-2xl rounded-tr-none px-3 py-2 max-w-[80%]">
                    <p className="text-sm text-white whitespace-pre-wrap">{m.text}</p>
                  </div>
                </div>
              ),
            )}
            {sending && (
              <div className="flex items-start gap-2">
                <div className="w-7 h-7 rounded-full bg-[#008899] flex items-center justify-center flex-shrink-0">
                  <Bot className="text-white" size={14} />
                </div>
                <div className="bg-white border border-gray-200 rounded-2xl rounded-tl-none px-3 py-2">
                  <div className="flex gap-1">
                    <span className="w-1.5 h-1.5 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0ms' }} />
                    <span className="w-1.5 h-1.5 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '120ms' }} />
                    <span className="w-1.5 h-1.5 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '240ms' }} />
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* Input */}
          <div className="px-3 py-2 border-t border-gray-200 bg-white">
            <div className="flex items-center gap-2">
              <input
                ref={inputRef}
                type="text"
                value={input}
                onChange={(e) => setInput(e.target.value)}
                onKeyDown={handleKeyDown}
                placeholder="Escribe un mensaje..."
                disabled={sending}
                className="flex-1 px-3 py-2 bg-gray-100 rounded-full text-sm focus:outline-none focus:ring-2 focus:ring-[#008899] disabled:opacity-60"
              />
              <button
                onClick={handleSend}
                disabled={sending || !input.trim()}
                aria-label="Enviar"
                className="bg-[#008899] p-2 rounded-full disabled:opacity-50"
              >
                <Send className="text-white" size={18} />
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
