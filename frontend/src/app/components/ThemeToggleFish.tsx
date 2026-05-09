import { motion } from 'motion/react';

type Theme = 'claro' | 'oscuro';

interface ThemeToggleFishProps {
  theme: Theme;
  onToggle: () => void;
  busy?: boolean;
}

export function ThemeToggleFish({ theme, onToggle, busy }: ThemeToggleFishProps) {
  const isDark = theme === 'oscuro';
  const ariaLabel = isDark ? 'Cambiar a tema claro' : 'Cambiar a tema oscuro';

  return (
    <button
      type="button"
      onClick={onToggle}
      disabled={busy}
      aria-label={ariaLabel}
      title={ariaLabel}
      className="fixed top-3 right-3 z-50 w-12 h-12 rounded-full overflow-hidden shadow-lg ring-2 ring-white/70 disabled:opacity-60 focus:outline-none focus:ring-[#008899]"
    >
      <motion.div
        className="absolute inset-0"
        initial={false}
        animate={{
          background: isDark
            ? 'linear-gradient(180deg, #0b1d3a 0%, #16306b 35%, #0e3b66 35%, #051a3a 100%)'
            : 'linear-gradient(180deg, #fde68a 0%, #fcd34d 35%, #38bdf8 35%, #0284c7 100%)',
        }}
        transition={{ duration: 0.6, ease: 'easeInOut' }}
      />
      <div className="absolute left-1 right-1 top-[35%] h-px bg-white/40" />
      <motion.div
        className="absolute"
        style={{ width: 28, left: '50%', marginLeft: -14 }}
        initial={false}
        animate={
          isDark
            ? { top: ['12%', '78%', '58%'], rotate: [-18, 30, 14] }
            : { top: ['58%', '-2%', '12%'], rotate: [14, -32, -18] }
        }
        transition={{
          duration: 0.75,
          ease: [0.22, 1, 0.36, 1],
          times: [0, 0.55, 1],
        }}
      >
        <FishSvg />
      </motion.div>
    </button>
  );
}

function FishSvg() {
  return (
    <svg viewBox="0 0 100 50" width="28" height="14" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <linearGradient id="fishBody" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor="#3b7a8a" />
          <stop offset="55%" stopColor="#1f4f5e" />
          <stop offset="100%" stopColor="#163a48" />
        </linearGradient>
      </defs>
      <path d="M 75 25 L 96 8 L 96 42 Z" fill="#163a48" />
      <ellipse cx="42" cy="25" rx="32" ry="14" fill="url(#fishBody)" />
      <ellipse cx="42" cy="33" rx="22" ry="5" fill="#5a8b9a" opacity="0.55" />
      <path d="M 38 12 Q 50 4 60 14" fill="#163a48" />
      <path d="M 35 28 Q 30 36 44 36" fill="#1f4f5e" />
      <path d="M 22 18 Q 18 25 22 32" stroke="#0d2730" strokeWidth="0.8" fill="none" />
      <circle cx="18" cy="22" r="2.6" fill="white" />
      <circle cx="18" cy="22" r="1.5" fill="#0d2730" />
      <circle cx="17.4" cy="21.4" r="0.6" fill="white" />
      <path d="M 9 26 Q 7 28 9 30" stroke="#0d2730" strokeWidth="0.8" fill="none" />
    </svg>
  );
}
