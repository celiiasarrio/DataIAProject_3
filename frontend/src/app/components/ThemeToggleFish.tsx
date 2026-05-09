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
      className="fixed top-3 right-5 z-50 w-12 h-12 rounded-full overflow-hidden shadow-lg ring-2 ring-white/70 disabled:opacity-60 focus:outline-none focus:ring-[#008899]"
    >
      <motion.div
        className="absolute inset-0"
        initial={false}
        animate={{
          background: isDark
            ? 'linear-gradient(180deg, #0b1d3a 0%, #16306b 35%, #0e3b66 35%, #051a3a 100%)'
            : 'linear-gradient(180deg, #ffffff 0%, #f0f9ff 35%, #4cc4dd 35%, #008899 100%)',
        }}
        transition={{ duration: 0.6, ease: 'easeInOut' }}
      />
      <div className="absolute left-1 right-1 top-[35%] h-px bg-white/50" />
      <motion.div
        className="absolute"
        style={{ width: 26, left: '50%', marginLeft: -13 }}
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
    <svg viewBox="0 0 120 60" width="26" height="13" xmlns="http://www.w3.org/2000/svg">
      <ellipse cx="42" cy="30" rx="40" ry="22" fill="#008899" />
      <path d="M 78 30 L 115 10 L 102 30 L 115 50 Z" fill="#008899" />
      <circle cx="22" cy="25" r="4" fill="#ffffff" />
    </svg>
  );
}
