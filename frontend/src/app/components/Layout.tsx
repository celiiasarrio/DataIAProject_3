import { Outlet } from 'react-router';
import { useEffect, useState } from 'react';
import { BottomNav } from './BottomNav';
import { FloatingAgent } from './FloatingAgent';
import { ThemeToggleFish } from './ThemeToggleFish';
import { updateProfileSection } from '../api/client';

type Theme = 'claro' | 'oscuro';

function readStoredTheme(): Theme {
  return (localStorage.getItem('profileTheme') as Theme) || 'claro';
}

export function Layout() {
  const [theme, setTheme] = useState<Theme>(readStoredTheme);
  const [themeBusy, setThemeBusy] = useState(false);

  useEffect(() => {
    document.documentElement.classList.toggle('dark', theme === 'oscuro');
  }, [theme]);

  const handleToggleTheme = async () => {
    if (themeBusy) return;
    const previous = theme;
    const next: Theme = previous === 'claro' ? 'oscuro' : 'claro';
    setTheme(next);
    localStorage.setItem('profileTheme', next);
    setThemeBusy(true);
    try {
      await updateProfileSection('preferences', { tema: next });
    } catch {
      setTheme(previous);
      localStorage.setItem('profileTheme', previous);
    } finally {
      setThemeBusy(false);
    }
  };

  return (
    <div className="min-h-screen bg-white dark:bg-gray-950">
      <ThemeToggleFish theme={theme} onToggle={handleToggleTheme} busy={themeBusy} />
      <Outlet />
      <FloatingAgent />
      <BottomNav />
    </div>
  );
}
