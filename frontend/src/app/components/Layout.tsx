import { Outlet } from 'react-router';
import { BottomNav } from './BottomNav';
import { FloatingAgent } from './FloatingAgent';

export function Layout() {
  return (
    <div className="min-h-screen bg-white">
      <Outlet />
      <FloatingAgent />
      <BottomNav />
    </div>
  );
}
