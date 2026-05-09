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
        style={{ width: 36, left: '50%', marginLeft: -18 }}
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
    <svg viewBox="0 0 140 80" width="36" height="20" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <linearGradient id="fishBody" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor="#5a7a78" />
          <stop offset="45%" stopColor="#2d4d4f" />
          <stop offset="100%" stopColor="#1a3537" />
        </linearGradient>
        <linearGradient id="fishBelly" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor="#3d5d5e" />
          <stop offset="100%" stopColor="#6a8b8c" />
        </linearGradient>
      </defs>
      <path
        d="M 100 40 Q 122 18 134 26 Q 130 40 134 54 Q 122 62 100 40 Z"
        fill="#1a3537"
      />
      <path
        d="M 96 30 Q 116 22 122 28 Q 116 36 100 38 Z"
        fill="#1f3c3e"
      />
      <path
        d="M 96 50 Q 116 58 122 52 Q 116 44 100 42 Z"
        fill="#1f3c3e"
      />
      <path
        d="M 18 42
           C 18 22 32 12 56 11
           C 84 10 100 20 106 32
           C 110 40 106 50 100 56
           C 86 66 60 68 38 64
           C 22 60 18 52 18 42 Z"
        fill="url(#fishBody)"
      />
      <path
        d="M 28 50
           C 40 64 70 66 92 60
           C 100 58 104 54 106 50
           C 100 56 86 60 60 60
           C 44 60 32 56 28 50 Z"
        fill="url(#fishBelly)"
      />
      <path
        d="M 40 14 Q 60 4 92 14 Q 96 18 96 22 Q 80 22 56 22 Q 44 22 40 14 Z"
        fill="#1a3537"
      />
      <path
        d="M 52 44 Q 44 58 62 56 Q 58 48 52 44 Z"
        fill="#1f3c3e"
      />
      <path
        d="M 28 28 Q 24 42 30 56"
        stroke="#0a1f20"
        strokeWidth="1.3"
        fill="none"
        opacity="0.7"
      />
      <path
        d="M 50 28 Q 56 32 50 36"
        stroke="#0a1f20"
        strokeWidth="0.5"
        fill="none"
        opacity="0.4"
      />
      <path
        d="M 64 28 Q 70 32 64 36"
        stroke="#0a1f20"
        strokeWidth="0.5"
        fill="none"
        opacity="0.4"
      />
      <path
        d="M 78 28 Q 84 32 78 36"
        stroke="#0a1f20"
        strokeWidth="0.5"
        fill="none"
        opacity="0.4"
      />
      <circle cx="24" cy="34" r="3.2" fill="#f5f5e8" />
      <circle cx="24" cy="34" r="1.8" fill="#0a1f20" />
      <circle cx="23.4" cy="33.4" r="0.6" fill="#ffffff" />
      <path
        d="M 14 38 Q 10 42 14 46 L 18 45 L 18 39 Z"
        fill="#0a1f20"
      />
      <path
        d="M 14 41 L 18 41"
        stroke="#5a7a78"
        strokeWidth="0.4"
      />
    </svg>
  );
}
