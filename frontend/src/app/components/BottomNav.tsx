import { Home, Calendar, User } from 'lucide-react';
import { useLocation, useNavigate } from 'react-router';

export function BottomNav() {
  const location = useLocation();
  const navigate = useNavigate();

  const navItems = [
    { icon: Home, path: '/dashboard', label: 'Inicio' },
    { icon: Calendar, path: '/calendar', label: 'Calendario' },
    { icon: User, path: '/profile', label: 'Perfil' },
  ];

  // Don't show on login page
  if (location.pathname === '/') {
    return null;
  }

  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 px-4 py-2 safe-area-inset-bottom">
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
                className={isActive ? 'text-[#008899]' : 'text-gray-400'}
              />
              <span className={`text-xs ${isActive ? 'text-[#008899]' : 'text-gray-400'}`}>
                {item.label}
              </span>
            </button>
          );
        })}
      </div>
    </nav>
  );
}