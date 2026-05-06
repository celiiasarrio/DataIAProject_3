import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useState,
  type ReactNode,
} from 'react';

export type Theme = 'claro' | 'oscuro';

type ThemeContextValue = {
  theme: Theme;
  setTheme: (theme: Theme) => void;
  toggleTheme: () => void;
};

const ThemeContext = createContext<ThemeContextValue | null>(null);

const STORAGE_KEY = 'profileTheme';

function readInitialTheme(): Theme {
  if (typeof window === 'undefined') return 'claro';
  const stored = window.localStorage.getItem(STORAGE_KEY);
  if (stored === 'oscuro' || stored === 'claro') return stored;
  const prefersDark = window.matchMedia?.('(prefers-color-scheme: dark)').matches ?? false;
  return prefersDark ? 'oscuro' : 'claro';
}

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [theme, setThemeState] = useState<Theme>(() => readInitialTheme());

  useEffect(() => {
    const root = document.documentElement;
    if (theme === 'oscuro') root.classList.add('dark');
    else root.classList.remove('dark');
    window.localStorage.setItem(STORAGE_KEY, theme);
  }, [theme]);

  useEffect(() => {
    const onStorage = (event: StorageEvent) => {
      if (event.key === STORAGE_KEY && (event.newValue === 'oscuro' || event.newValue === 'claro')) {
        setThemeState(event.newValue);
      }
    };
    window.addEventListener('storage', onStorage);
    return () => window.removeEventListener('storage', onStorage);
  }, []);

  const setTheme = useCallback((next: Theme) => setThemeState(next), []);
  const toggleTheme = useCallback(
    () => setThemeState((current) => (current === 'oscuro' ? 'claro' : 'oscuro')),
    [],
  );

  return (
    <ThemeContext.Provider value={{ theme, setTheme, toggleTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

export function useTheme() {
  const ctx = useContext(ThemeContext);
  if (!ctx) throw new Error('useTheme must be used within <ThemeProvider>');
  return ctx;
}
