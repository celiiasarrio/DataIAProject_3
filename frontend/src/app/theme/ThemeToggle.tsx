import { useTheme } from './ThemeContext';

type ThemeToggleProps = {
  className?: string;
};

export function ThemeToggle({ className = '' }: ThemeToggleProps) {
  const { theme, toggleTheme } = useTheme();
  const isDark = theme === 'oscuro';

  return (
    <button
      type="button"
      onClick={toggleTheme}
      aria-label={isDark ? 'Activar modo claro' : 'Activar modo oscuro'}
      title={isDark ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro'}
      className={`relative w-9 h-9 rounded-full overflow-hidden shadow-md ring-1 ring-white/40 dark:ring-slate-700 ${className}`}
      style={{
        background: isDark
          ? 'linear-gradient(to bottom, #0b1220 0%, #0b1220 22%, #0b3550 22%, #062338 100%)'
          : 'linear-gradient(to bottom, #ddf6ff 0%, #ddf6ff 62%, #4cc4dd 62%, #008899 100%)',
        transition: 'background 0.6s ease',
      }}
    >
      <span
        aria-hidden
        className="absolute left-1/2 select-none pointer-events-none"
        style={{
          fontSize: 16,
          lineHeight: 1,
          top: isDark ? '54%' : '4%',
          transform: `translateX(-50%) ${isDark ? 'rotate(15deg) scale(0.95)' : 'rotate(-15deg) scale(1)'}`,
          // Salto: easing con overshoot para que el pez se "lance" al cambiar a claro
          // Inmersión: easing acelerado para que el pez "se hunda" al cambiar a oscuro
          transition: isDark
            ? 'top 0.55s cubic-bezier(0.55, 0.0, 0.6, 1), transform 0.55s cubic-bezier(0.55, 0.0, 0.6, 1)'
            : 'top 0.6s cubic-bezier(0.34, 1.56, 0.64, 1), transform 0.6s cubic-bezier(0.34, 1.56, 0.64, 1)',
          filter: isDark ? 'brightness(0.85)' : 'none',
        }}
      >
        🐟
      </span>
    </button>
  );
}
