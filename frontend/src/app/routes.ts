import { createBrowserRouter } from 'react-router';
import { LoginScreen } from './components/LoginScreen';
import { DashboardScreen } from './components/DashboardScreen';
import { CalendarScreen } from './components/CalendarScreen';
import { RoomBookingScreen } from './components/RoomBookingScreen';
import { ChatScreen } from './components/ChatScreen';
import { ProfileScreen } from './components/ProfileScreen';
import { GradesScreen } from './components/GradesScreen';
import { AttendanceScreen } from './components/AttendanceScreen';
import { NotificationsScreen } from './components/NotificationsScreen';
import { CoursesScreen } from './components/CoursesScreen';
import { CourseDetailScreen } from './components/CourseDetailScreen';
import { GradingScreen } from './components/GradingScreen';
import { TeacherGradesScreen } from './components/TeacherGradesScreen';
import { ClassAttendanceScreen } from './components/ClassAttendanceScreen';
import { TasksScreen } from './components/TasksScreen';
import { Layout } from './components/Layout';


export const router = createBrowserRouter([
  {
    path: '/',
    Component: LoginScreen,
  },
  {
    path: '/',
    Component: Layout,
    children: [
      { path: 'dashboard',                                    Component: DashboardScreen      },
      { path: 'calendar',                                     Component: CalendarScreen       },
      { path: 'profile',                                      Component: ProfileScreen        },
      { path: 'rooms',                                        Component: RoomBookingScreen    },
      { path: 'chat',                                         Component: ChatScreen           },
      { path: 'grades',                                       Component: GradesScreen         },
      { path: 'attendance',                                   Component: AttendanceScreen     },
      { path: 'deliveries',                                   Component: TasksScreen          },
      { path: 'notifications',                                Component: NotificationsScreen  },
      { path: 'courses',                                      Component: CoursesScreen        },
      { path: 'courses/:courseId',                            Component: CourseDetailScreen   },
      { path: 'courses/:courseId/blocks/:blockId/grade',      Component: GradingScreen        },
      { path: 'teacher/grades',                               Component: TeacherGradesScreen  },
      { path: 'sessions/:sessionId/attendance',               Component: ClassAttendanceScreen},
    ],
  },
]);
