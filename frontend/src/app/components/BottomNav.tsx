import { Home, Calendar, User, BookOpen, FolderOpen, MessageSquare } from 'lucide-react';
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
        { icon: MessageSquare, path: '/tutoring', label: 'Tutorías' },
        { icon: User, path: '/profile', label: 'Perfil' },
      ];
    } else if (userRole === 'professor') {
      return [
        ...baseItems,
        { icon: Calendar, path: '/calendar', label: 'Mis Clases' },
        { icon: BookOpen, path: '/teacher/grades', label: 'Notas' },
        { icon: FolderOpen, path: '/teacher/content', label: 'Material' },
        { icon: MessageSquare, path: '/tutoring', label: 'Tutorías' },
        { icon: User, path: '/profile', label: 'Perfil' },
      ];
    } else {
      // admin/coordinator
      return [
        ...baseItems,
        { icon: Calendar, path: '/calendar', label: 'Calendario' },
        { icon: BookOpen, path: '/teacher/grades', label: 'Notas' },
        { icon: FolderOpen, path: '/teacher/content', label: 'Material' },
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
