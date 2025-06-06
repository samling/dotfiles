import { getPosition } from 'src/lib/utils.js';
import { bind, Variable } from 'astal';
import { trackActiveMonitor, trackAutoTimeout, trackPopupNotifications } from './helpers.js';
import { Astal } from 'astal/gtk3';
import { NotificationCard } from './Notification.js';
import AstalNotifd from 'gi://AstalNotifd?version=0.1';
import AstalHyprland from 'gi://AstalHyprland?version=0.1';
import { GdkMonitorMapper } from '../bar/utils/GdkMonitorMapper';
import { NotificationAnchor } from 'src/lib/types/options';

const hyprlandService = AstalHyprland.get_default();
const position = Variable<NotificationAnchor>('top right');
const monitor = Variable(0);
const active_monitor = Variable(true);
const showActionsOnHover = Variable(false);
const displayedTotal = Variable(10);

const tear = Variable(false);

const curMonitor = Variable(monitor.get());
const popupNotifications: Variable<AstalNotifd.Notification[]> = Variable([]);

trackActiveMonitor(curMonitor);
trackPopupNotifications(popupNotifications);
trackAutoTimeout();

export default (): JSX.Element => {
    const gdkMonitorMapper = new GdkMonitorMapper();

    const windowLayer = bind(tear).as((tear) => (tear ? Astal.Layer.TOP : Astal.Layer.OVERLAY));
    const windowAnchor = bind(position).as(getPosition);
    const windowMonitor = Variable.derive(
        [bind(hyprlandService, 'focusedMonitor'), bind(monitor), bind(active_monitor)],
        (focusedMonitor, monitor, activeMonitor) => {
            gdkMonitorMapper.reset();

            if (activeMonitor === true) {
                const gdkMonitor = gdkMonitorMapper.mapHyprlandToGdk(focusedMonitor.id);
                return gdkMonitor;
            }

            const gdkMonitor = gdkMonitorMapper.mapHyprlandToGdk(monitor);
            return gdkMonitor;
        },
    );

    const notificationsBinding = Variable.derive(
        [bind(popupNotifications), bind(showActionsOnHover)],
        (notifications, showActions) => {
            const maxDisplayed = notifications.slice(0, displayedTotal.get());
            
            // Reverse the array to display new notifications at the top
            return [...maxDisplayed].reverse().map((notification) => {
                return <NotificationCard notification={notification} showActions={showActions} />;
            });
        },
    );

    return (
        <window
            name={'notifications-window'}
            namespace={'notifications-window'}
            className={'notifications-window'}
            layer={windowLayer}
            anchor={windowAnchor}
            exclusivity={Astal.Exclusivity.NORMAL}
            monitor={windowMonitor()}
            onDestroy={() => {
                windowMonitor.drop();
                notificationsBinding.drop();
            }}
        >
            <box vertical hexpand className={'notification-card-container'}>
                {notificationsBinding()}
            </box>
        </window>
    );
};
