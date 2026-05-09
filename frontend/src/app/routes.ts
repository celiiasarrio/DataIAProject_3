import { createBrowserRouter } from 'react-router';
import { createElement } from 'react';
import { Navigate } from 'react-router';
import { LoginScreen } from './components/LoginScreen';
import { DashboardScreen } from './components/DashboardScreen';
import { CalendarScreen } from './components/CalendarScreen';
import { ChatScreen } from './components/ChatScreen';
import { ProfileScreen } from './components/ProfileScreen';
import { GradesScreen } from './components/GradesScreen';
import { AttendanceScreen } from './components/AttendanceScreen';
import { CoursesScreen } from './components/CoursesScreen';
import { CourseDetailScreen } from './components/CourseDetailScreen';
import { GradingScreen } from './components/GradingScreen';
import { TeacherGradesScreen } from './components/TeacherGradesScreen';
import { TeacherContentScreen } from './components/TeacherContentScreen';
import { ClassAttendanceScreen } from './components/ClassAttendanceScreen';
import { GroupAttendanceScreen } from './components/GroupAttendanceScreen';
import { TutoringScreen } from './components/TutoringScreen';
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
      { path: 'rooms',                                        element: createElement(Navigate, { to: '/dashboard', replace: true }) },
      { path: 'chat',                                         Component: ChatScreen           },
      { path: 'grades',                                       Component: GradesScreen         },
      { path: 'attendance',                                   Component: AttendanceScreen     },
      { path: 'notifications',                                element: createElement(Navigate, { to: '/dashboard', replace: true }) },
      { path: 'tutoring',                                     Component: TutoringScreen       },
      { path: 'courses',                                      Component: CoursesScreen        },
      { path: 'courses/:courseId',                            Component: CourseDetailScreen   },
      { path: 'courses/:courseId/blocks/:blockId/grade',      Component: GradingScreen        },
      { path: 'teacher/grades',                               Component: TeacherGradesScreen  },
      { path: 'teacher/content',                              Component: TeacherContentScreen },
      { path: 'group-attendance',                             Component: GroupAttendanceScreen},
      { path: 'sessions/:sessionId/attendance',               Component: ClassAttendanceScreen},
    ],
  },
]);
