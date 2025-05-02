import MediaMenu from './media/index.js';
import NotificationsMenu from './notifications/index.js';
import CalendarMenu from './calendar/index.js';
import AudioMenu from './audio/index.js';
import EnergyMenu from './energy/index.js';
import DashboardMenu from './dashboard/index.js';
import PowerDropdownMenu from './powerDropdown/index.js';
import PowerMenu from './power/index.js';
import Verification from './power/verification.js';
export const DropdownMenus = [
    MediaMenu,
    NotificationsMenu,
    CalendarMenu,
    AudioMenu,
    EnergyMenu,
    DashboardMenu,
    PowerDropdownMenu,
];

export const StandardWindows = [PowerMenu, Verification];