import { App } from "astal/gtk3"
import style from "./style/main.scss"
import Bar from "./widget/Bar/Bar"
import ControlCenter from "./widget/ControlCenter/ControlCenter"
import MediaWindow from "./widget/MediaWindow/Media"
import CalendarWindow from "./widget/Calendar"
import OSDWindow from "./widget/OSD"
import NotificationPopups from "./widget/Notification"

App.start({
    css: style,
    main() {
        const mainMonitor = App.get_monitors()[3]

        Bar(mainMonitor)
        ControlCenter(mainMonitor)
        MediaWindow(mainMonitor)
        CalendarWindow(mainMonitor)
        OSDWindow(mainMonitor)
        NotificationPopups(mainMonitor)
    }
})

