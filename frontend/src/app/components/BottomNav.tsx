import { Home, Calendar, User } from 'lucide-react';
import { useLocation, useNavigate } from 'react-router';

export function BottomNav() {
  const location = useLocation();
  const navigate = useNavigate();
  const userRole = localStorage.getItem('userRole') || 'student';

  const getNavItems = () => {
    const baseItems = [
      { icon: Home, path: '/dashboard', label: 'Inicio' },
    ];

    if (userRole === 'student') {
      return [
        ...baseItems,
        { icon: Calendar, path: '/calendar', label: 'Calendario' },
        { icon: User, path: '/profile', label: 'Perfil' },
      ];
    } else if (userRole === 'professor') {
      return [
        ...baseItems,
        { icon: Calendar, path: '/calendar', label: 'Mis Clases' },
        { icon: User, path: '/profile', label: 'Perfil' },
      ];
    } else {
      // admin/coordinator
      return [
        ...baseItems,
        { icon: Calendar, path: '/calendar', label: 'Calendario' },
        { icon: User, path: '/profile', label: 'Perfil' },
      ];
    }
  };

  const navItems = getNavItems();

  // Don't show on login page
  if (location.pathname === '/') {
    return null;
  }

  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-white dark:bg-gray-900 border-t border-gray-200 dark:border-gray-800 px-4 py-2 safe-area-inset-bottom">
      <div className="flex items-center justify-around max-w-md mx-auto">
        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = location.pathname === item.path;
          
          return (
            <button
              key={item.path}
              onClick={() => navigate(item.path)}
              className="flex flex-col items-center gap-1 p-2"
            >
              <Icon
                size={24}
                className={isActive ? 'text-[#008899] dark:text-cyan-300' : 'text-gray-400 dark:text-gray-500'}
              />
              <span className={`text-xs ${isActive ? 'text-[#008899] dark:text-cyan-300' : 'text-gray-400 dark:text-gray-500'}`}>
                {item.label}
              </span>
            </button>
          );
        })}
      </div>
    </nav>
  );
}
