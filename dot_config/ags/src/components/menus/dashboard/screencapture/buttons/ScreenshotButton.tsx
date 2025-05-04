import { bind, timeout, Variable } from 'astal';
import { App, Gdk, Gtk } from 'astal/gtk3';
import Menu from 'src/components/shared/Menu';
import MenuItem from 'src/components/shared/MenuItem';
import { getRecordingPath, executeCommand } from '../helpers';
import AstalHyprland from 'gi://AstalHyprland?version=0.1';

const hyprlandService = AstalHyprland.get_default();

const MonitorListDropdown = (): JSX.Element => {
    const monitorList: Variable<AstalHyprland.Monitor[]> = Variable([]);

    const monitorBinding = Variable.derive([bind(hyprlandService, 'monitors')], () => {
        monitorList.set(hyprlandService.get_monitors());
    });

    const activeDisplay = Variable.derive([bind(hyprlandService, 'focused_monitor')], () => {
        return hyprlandService.get_focused_monitor();
    });

    return (
        <Menu className={'dropdown screenshot'} halign={Gtk.Align.FILL} onDestroy={() => monitorBinding.drop()} hexpand>
            <MenuItem
                label={`Display ${activeDisplay.get()?.name}`}
                onButtonPressEvent={(_, event) => {
                    if (event.get_button()[1] !== Gdk.BUTTON_PRIMARY) return;

                    App.get_window('dashboardmenu')?.set_visible(false);
                    timeout(100, () => {
                        const sanitizedPath = getRecordingPath().replace(/"/g, '\\"');
                        const command = `${SRC_DIR}/scripts/snapshot.sh output "${sanitizedPath}"`;
                        executeCommand(command);
                    });
                }}
            />

            <MenuItem
                label="Region"
                onButtonPressEvent={(_, event) => {
                    if (event.get_button()[1] !== Gdk.BUTTON_PRIMARY) return;

                    App.get_window('dashboardmenu')?.set_visible(false);
                    timeout(100, () => {
                        const sanitizedPath = getRecordingPath().replace(/"/g, '\\"');
                        const command = `${SRC_DIR}/scripts/snapshot.sh area "${sanitizedPath}"`;
                        executeCommand(command);
                    });
                }}
            />
        </Menu>
    );
};

export const ScreenshotButton = (): JSX.Element => {
    return (
        <button
            className={`dashboard-button screenshot`}
            tooltipText="Screenshot"
            vexpand
            onButtonPressEvent={(_, event) => {
                const buttonClicked = event.get_button()[1];

                if (buttonClicked !== Gdk.BUTTON_PRIMARY) {
                    return;
                }

                const monitorDropdownList = MonitorListDropdown() as Gtk.Menu;
                monitorDropdownList.popup_at_pointer(event);
            }}
        >
            <label className={'button-label txt-icon'} label={''} />
        </button>
    );
};
