import { Outlet } from 'react-router';
import { useEffect, useState } from 'react';
import { BottomNav } from './BottomNav';
import { FloatingAgent } from './FloatingAgent';

type Theme = 'claro' | 'oscuro';

function readStoredTheme(): Theme {
  return (localStorage.getItem('profileTheme') as Theme) || 'claro';
}

export function Layout() {
  const [theme] = useState<Theme>(readStoredTheme);

  useEffect(() => {
    document.documentElement.classList.toggle('dark', theme === 'oscuro');
  }, [theme]);

  return (
    <div className="min-h-screen bg-white dark:bg-gray-950">
      <Outlet />
      <FloatingAgent />
      <BottomNav />
    </div>
  );
}
